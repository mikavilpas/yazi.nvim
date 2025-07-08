---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziSessionHighlighter =
  require("yazi.buffer_highlighting.yazi_session_highlighter")

---@class YaProcess
---@field public hovered_url? string "The path that is currently hovered over in this yazi."
---@field public cwd? string "The path that the yazi process is currently in."
---@field private config YaziConfig
---@field public yazi_id string "The YAZI_ID of the yazi process"
---@field private ya_process vim.SystemObj
---@field private retries integer
---@field private highlighter YaziSessionHighlighter
---@field private on_first_output fun()
---@field public ready boolean
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
  self.retries = 0
  self.highlighter = YaziSessionHighlighter.new()
  self.on_first_output = on_first_output
  self.ready = false

  return self
end

function YaProcess:is_ready()
  local has_process = self.ya_process ~= nil
  local on_first_output_called = self.on_first_output == nil
  local is_ready = self.ready == true
  local ready = has_process and on_first_output_called and is_ready
  return ready,
    {
      has_process = has_process,
      on_first_output_called = on_first_output_called,
      is_ready = is_ready,
    }
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
      table.insert(command_words, vim.fn.shellescape(path.filename))
    end
  else
    table.insert(command_words, vim.fn.shellescape(paths[1].filename))
  end

  table.insert(command_words, "--chooser-file")
  table.insert(command_words, self.config.chosen_file_path)

  if self.yazi_id then
    table.insert(command_words, "--client-id")
    table.insert(command_words, self.yazi_id)
  end

  command_words = remove_duplicates(command_words)

  return table.concat(command_words, " ")
end

---@param timeout integer
function YaProcess:kill_and_wait(timeout)
  Log:debug("Killing ya process")
  pcall(self.ya_process.kill, self.ya_process, "sigterm")
  self.highlighter:clear_highlights()

  Log:debug("Waiting for ya process to exit")
  self.ya_process:wait(timeout)
end

---@param context YaziActiveContext
function YaProcess:start(context)
  local event_kinds = {
    "rename",
    "delete",
    "trash",
    "move",
    "cd",
    "hover",
    "bulk",
    -- when ya starts, it will send a "hi" event to all yazis. They respond
    -- with "hey" to acknowledge this. We can use this to detect when ya is
    -- ready, so that integration-tests can safely start.
    "hey",
  }

  ---@type table<string,boolean>
  local interesting_events = {}
  if self.config.forwarded_dds_events ~= nil then
    for _, event_kind in ipairs(self.config.forwarded_dds_events) do
      event_kinds[#event_kinds + 1] = event_kind
      interesting_events[event_kind] = true
    end
  end

  local ya_command = {
    "ya",
    "sub",
    table.concat(event_kinds, ","),
  }
  Log:debug(
    string.format(
      "Opening ya with the command: (%s), attempt %s",
      table.concat(ya_command, " "),
      self.retries
    )
  )

  self.ya_process = vim.system(ya_command, {
    -- • text: (boolean) Handle stdout and stderr as text.
    -- Replaces `\r\n` with `\n`.
    text = true,
    stderr = function(err, data)
      if err then
        Log:debug(string.format("ya stderr error: '%s'", data))
      end

      if data == nil then
        -- weird event, ignore
        return
      end

      Log:debug(string.format("ya stderr: '%s'", data))

      if data:find("No running Yazi instance found") then
        if self.retries < 5 then
          Log:debug(
            "Looks like starting ya failed because yazi had not started yet. Retrying to open ya..."
          )
          self.retries = self.retries + 1
          vim.defer_fn(function()
            self:start(context)
          end, 50)
        else
          Log:debug("Failed to open ya after 5 retries")
        end
      end
    end,

    stdout = function(err, data)
      if err then
        Log:debug(string.format("ya stdout error: '%s'", data))
      end
      data = data or ""
      data = data:gsub("\n+", "\n")

      if not data:match("^hey") then
        Log:debug(string.format("ya stdout: '%s'", data))
      end

      data = vim.split(data, "\n", { plain = true, trimempty = true })

      local parsed = utils.safe_parse_events(data)
      -- Log:debug(string.format("Parsed events: %s", vim.inspect(parsed)))

      self:process_events(parsed, interesting_events, context)
    end,

    ---@param obj vim.SystemCompleted
    on_exit = function(obj)
      Log:debug(string.format("ya process exited with code: %s", obj.code))
    end,
  })

  return self
end

---@param events YaziEvent[]
---@param forwarded_event_kinds table<string,boolean>
---@param context YaziActiveContext
function YaProcess:process_events(events, forwarded_event_kinds, context)
  local nvim_event_handling = require("yazi.event_handling.nvim_event_handling")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  for _, event in ipairs(events) do
    if self.ready ~= true and event.type == "hey" then
      ---@cast event YaziHeyEvent
      if event.yazi_id == self.yazi_id then
        Log:debug(
          string.format("ya process is ready, yazi_id: %s", self.yazi_id)
        )
        self.ready = true
        self.on_first_output()
        self.on_first_output = nil
      end
    elseif event.type == "hover" then
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
        self.highlighter:highlight_buffers_when_hovered(event.url, self.config)
        nvim_event_handling.emit("YaziDDSHover", event)
      end)
    elseif event.type == "cd" then
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
    else
      if
        event.type == "rename"
        or event.type == "move"
        or event.type == "bulk"
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
end

return YaProcess
