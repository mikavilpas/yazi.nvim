---@module "plenary.path"

local Log = require("yazi.log")
local event_source = require("yazi.process.event_source")
local utils = require("yazi.utils")
local YaziSessionHighlighter =
  require("yazi.buffer_highlighting.yazi_session_highlighter")

---Tracks the state of one running yazi (what is hovered, where it is) and
---turns the events it reports into changes in Neovim.
---
---Where those events come from is the business of the `yazi.EventSource` it
---holds - either a separate `ya sub` process or yazi's own stdout.
---
---@class YaProcess
---@field public hovered_url? string "The path that is currently hovered over in this yazi."
---@field public cwd? string "The path that the yazi process is currently in."
---@field private config YaziConfig
---@field public yazi_id string "The YAZI_ID of the yazi process"
---@field public event_source yazi.EventSource
---@field private highlighter YaziSessionHighlighter
---@field private on_first_output fun()
---@field public ready boolean
---@field private forwarded_event_kinds table<string, boolean>
local YaProcess = {}
---@diagnostic disable-next-line: inject-field
YaProcess.__index = YaProcess

---@param config YaziConfig
---@param yazi_id string
---@param on_first_output fun(self: YaProcess, event: YaziEvent)
---@param initial_file string
function YaProcess.new(config, yazi_id, on_first_output, initial_file)
  local self = setmetatable({}, YaProcess)

  self.yazi_id = yazi_id
  self.hovered_url = initial_file
  self.config = config
  self.highlighter = YaziSessionHighlighter.new()
  self.on_first_output = on_first_output
  self.ready = false
  self.event_source = event_source.create(config, yazi_id)

  local _, forwarded_event_kinds = event_source.event_kinds(config)
  self.forwarded_event_kinds = forwarded_event_kinds

  return self
end

function YaProcess:id()
  return "yazi-"
    .. self.yazi_id
    .. "-"
    .. self.event_source.name
    .. "-"
    .. self.event_source:id()
end

function YaProcess:is_ready()
  local is_listening = self.event_source:is_listening()
  local on_first_output_called = self.on_first_output == nil
  local is_ready = self.ready == true
  local ready = is_listening and on_first_output_called and is_ready
  return ready,
    {
      id = self:id(),
      event_source = self.event_source.name,
      is_listening = is_listening,
      on_first_output_called = on_first_output_called,
      is_ready = is_ready,
    }
end

---Set up the transport that will deliver yazi's events. Must be called before
---the yazi command line is built, because the source may need to put something
---in it.
---@param context YaziActiveContext
function YaProcess:open_event_source(context)
  local on_lines = function(lines)
    self:handle_event_lines(lines, context)
  end

  local ok, error_message = self.event_source:open(on_lines)
  if ok then
    return
  end

  Log:debug(
    string.format(
      "Could not use the '%s' event source (%s), falling back to `ya sub`",
      self.event_source.name,
      tostring(error_message)
    )
  )
  self.event_source = event_source.create_fallback(self.config, self.yazi_id)
  assert(self.event_source:open(on_lines))
end

---@param items string[]
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

---@param paths Path[]
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

  vim.list_extend(command_words, self.event_source:yazi_arguments())

  command_words = remove_duplicates(command_words)

  return command_words
end

---@param timeout integer
function YaProcess:kill_and_wait(timeout)
  self.highlighter:clear_highlights()
  self.event_source:close(timeout)
end

---Begin receiving events, now that yazi is running.
function YaProcess:start()
  self.event_source:start()
  return self
end

---Feed a batch of raw event lines, as reported by the event source, into the
---event handling.
---@param lines string[]
---@param context YaziActiveContext
function YaProcess:handle_event_lines(lines, context)
  local parsed = utils.safe_parse_events(lines)
  -- Log:debug(string.format("Parsed events: %s", vim.inspect(parsed)))

  self:process_events(parsed, self.forwarded_event_kinds, context)
end

---@param events YaziEvent[]
---@param forwarded_event_kinds table<string,boolean>
---@param context YaziActiveContext
function YaProcess:process_events(events, forwarded_event_kinds, context)
  for _, event in ipairs(events) do
    if self.ready ~= true and self.event_source:is_ready_signal(event) then
      Log:debug(
        string.format(
          "The event source (%s) is ready, yazi_id: %s",
          self.event_source.name,
          self.yazi_id
        )
      )
      self.ready = true
      self.on_first_output()
      self.on_first_output = nil
    end

    self:process_event(event, forwarded_event_kinds, context)
  end
end

---@private
---@param event YaziEvent
---@param forwarded_event_kinds table<string,boolean>
---@param context YaziActiveContext
function YaProcess:process_event(event, forwarded_event_kinds, context)
  local nvim_event_handling = require("yazi.event_handling.nvim_event_handling")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  if event.type == "hey" then
    -- a `ya sub` handshake, only interesting for detecting readiness above
    return
  elseif event.type == "hover" and event.yazi_id == self.yazi_id then
    -- Only track hovers from our own yazi. The DDS bus is shared across all
    -- yazi instances on the system, so other instances (e.g. another yazi
    -- the user has open, or a not-yet-exited one from a previous test) also
    -- broadcast `hover` events. Honoring them would corrupt our
    -- `hovered_url`. The `cd` handler below filters by `yazi_id` for the
    -- same reason.
    ---@cast event YaziHoverEvent
    Log:debug(
      string.format(
        "Changing the hovered url from %s to %s",
        self.hovered_url,
        event.url
      )
    )
    self.hovered_url = event.url
    vim.schedule(function()
      if self.config.highlight_hovered_buffers_in_same_directory then
        self.highlighter:highlight_buffers_when_hovered(event.url, self.config)
      else
        Log:debug("Skipping buffer highlighting (disabled in config)")
      end

      nvim_event_handling.emit("YaziDDSHover", event)
    end)
  elseif event.type == "cd" and event.yazi_id == self.yazi_id then
    ---@cast event YaziHoverEvent
    Log:debug(
      string.format("Changing the cwd from %s to %s", self.cwd, event.url)
    )
    self.cwd = event.url
  elseif event.type == "cycle-buffer" then
    vim.schedule(function()
      ---@cast event YaziNvimCycleBufferEvent
      yazi_event_handling.process_event_emitted_from_yazi(
        event,
        self.config,
        context
      )
    end)
  elseif event.type == "yazi-nvim" then
    ---@cast event YaziCustomDDSEvent
    vim.schedule(function()
      yazi_event_handling.process_plugin_keymap_event(
        event,
        self.yazi_id,
        self.config,
        context
      )
    end)
  else
    if
      event.type == "rename"
      or event.type == "move"
      or event.type == "bulk"
      or event.type == "bulk-rename"
    then
      vim.schedule(function()
        local success, result = pcall(function()
          nvim_event_handling.emit_renamed_or_moved_event(event)
        end)
        if not success then
          Log:debug(vim.inspect({
            "Failed to emit YaziRenamedOrMoved event",
            event,
            result,
          }))
        end

        yazi_event_handling.process_event_emitted_from_yazi(
          event,
          self.config,
          context
        )
      end)
    elseif forwarded_event_kinds[event.type] ~= nil then
      vim.schedule(function()
        nvim_event_handling.emit("YaziDDSCustom", event)
      end)
    else
      vim.schedule(function()
        yazi_event_handling.process_event_emitted_from_yazi(
          event,
          self.config,
          context
        )
      end)
    end
  end
end

return YaProcess
