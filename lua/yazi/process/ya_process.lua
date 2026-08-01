---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziSessionHighlighter = require("yazi.buffer_highlighting.yazi_session_highlighter")

---@class YaProcess
---@field public hovered_url? string
---@field public cwd? string
---@field private config YaziConfig
---@field public yazi_id string
---@field private highlighter YaziSessionHighlighter
---@field private on_first_output fun()
---@field public ready boolean
---@field private event_timer userdata?
---@field public get_pending_chunks fun(): string[]
local YaProcess = {}
YaProcess.__index = YaProcess

function YaProcess.new(config, yazi_id, on_first_output, initial_file)
  local self = setmetatable({}, YaProcess)
  self.yazi_id = yazi_id
  self.hovered_url = initial_file
  self.config = config
  self.highlighter = YaziSessionHighlighter.new()
  self.on_first_output = on_first_output
  self.ready = false
  return self
end

function YaProcess:is_ready()
  return self.ready == true, { is_ready = self.ready == true }
end

local function remove_duplicates(items)
  local seen = {}
  local result = {}
  for _, word in ipairs(items) do
    if not seen[word] then
      seen[word] = true
      result[#result + 1] = word
    end
  end
  return result
end

function YaProcess:get_events_list()
  local event_kinds = {
    "rename", "delete", "trash", "move", "cd", "hover", "bulk", "bulk-rename",
  }

  if self.config.future_features.yazi_plugin_keymaps ~= nil then
    event_kinds[#event_kinds + 1] = "yazi-nvim"
  end

  local interesting_events = {}
  if self.config.forwarded_dds_events ~= nil then
    for _, event_kind in ipairs(self.config.forwarded_dds_events) do
      event_kinds[#event_kinds + 1] = event_kind
      interesting_events[event_kind] = true
    end
  end

  return event_kinds, interesting_events
end

function YaProcess:get_yazi_command(paths)
  local command_words = { "yazi" }

  if self.config.open_multiple_tabs == true then
    for _, path in ipairs(paths) do
      table.insert(command_words, path.filename)
    end
  else
    table.insert(command_words, paths[1].filename)
  end

  table.insert(command_words, "--chooser-file")
  table.insert(command_words, self.config.chosen_file_path)

  if self.yazi_id then
    table.insert(command_words, "--client-id")
    table.insert(command_words, self.yazi_id)
  end

  if self.config.future_features.use_cwd_file then
    table.insert(command_words, "--cwd-file")
    table.insert(command_words, self.config.cwd_file_path)
  end

  local event_kinds, _ = self:get_events_list()
  table.insert(command_words, "--local-events=" .. table.concat(event_kinds, ","))

  return remove_duplicates(command_words)
end

function YaProcess:kill_and_wait(timeout)
  if self.event_timer then
    self.event_timer:stop()
    self.event_timer:close()
    self.event_timer = nil
  end
  self.highlighter:clear_highlights()
end

local function parse_local_events(lines)
  local events = {}
  for _, line in ipairs(lines) do
    line = vim.trim(line)
    if line ~= "" then
      local kind, receiver, sender, json_str = line:match("^([^,]+),([^,]+),([^,]+),(.*)$")
      if kind and json_str then
        local ok, decoded = pcall(vim.json.decode, json_str)
        local event = {
          type = kind,
          receiver = receiver,
          yazi_id = sender,
          raw_data = json_str,
          data = {},
        }
        if ok and type(decoded) == "table" then
          for k, v in pairs(decoded) do
            local clean_val = (v == vim.NIL) and nil or v
            event[k] = clean_val
            event.data[k] = clean_val
          end
        end
        table.insert(events, event)
      end
    end
  end
  return events
end

function YaProcess:start(context)
  if not self.ready then
    self.ready = true
    if self.on_first_output then
      self.on_first_output()
      self.on_first_output = nil
    end
  end
  self.read_buffer = ""
  return self
end

-- New function that processes data the millisecond it arrives over TCP
function YaProcess:receive_chunk(chunk, context)
  self.read_buffer = self.read_buffer .. chunk
  local lines = vim.split(self.read_buffer, "\n", { plain = true })
  
  -- The last item is either an incomplete string (no newline yet) or an empty string
  self.read_buffer = table.remove(lines) 

  if #lines > 0 then
    local parsed = parse_local_events(lines)
    local _, interesting_events = self:get_events_list()
    self:process_events(parsed, interesting_events, context)
  end
end


function YaProcess:process_events(events, forwarded_event_kinds, context)
  local nvim_event_handling = require("yazi.event_handling.nvim_event_handling")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  for _, event in ipairs(events) do
    if event.type == "hover" and event.yazi_id == self.yazi_id then
      ---@cast event YaziHoverEvent
      self.hovered_url = event.url
      vim.schedule(function()
        if self.config.highlight_hovered_buffers_in_same_directory and type(event.url) == "string" then
          self.highlighter:highlight_buffers_when_hovered(event.url, self.config)
        end
        nvim_event_handling.emit("YaziDDSHover", event)
      end)
    elseif event.type == "cd" and event.yazi_id == self.yazi_id then
      ---@cast event YaziHoverEvent
      self.cwd = event.url
    elseif event.type == "cycle-buffer" then
      vim.schedule(function()
        yazi_event_handling.process_event_emitted_from_yazi(event, self.config, context)
      end)
    elseif event.type == "yazi-nvim" then
      ---@cast event YaziCustomDDSEvent
      vim.schedule(function()
        yazi_event_handling.process_plugin_keymap_event(event, self.yazi_id, self.config, context)
      end)
    else
      if event.type == "rename" or event.type == "move" or event.type == "bulk" or event.type == "bulk-rename" then
        vim.defer_fn(function()
          pcall(function() nvim_event_handling.emit_renamed_or_moved_event(event) end)
          yazi_event_handling.process_event_emitted_from_yazi(event, self.config, context)
        end, 100)
      elseif forwarded_event_kinds[event.type] ~= nil then
        vim.schedule(function()
          nvim_event_handling.emit("YaziDDSCustom", event)
        end)
      else
        vim.schedule(function()
          yazi_event_handling.process_event_emitted_from_yazi(event, self.config, context)
        end)
      end
    end
  end
end

return YaProcess