---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziSessionHighlighter =
  require("yazi.buffer_highlighting.yazi_session_highlighter")

---@class (exact) YaProcess
---@field public events YaziEvent[] "The events that have been received from yazi"
---@field public new fun(config: YaziConfig, yazi_id: string): YaProcess
---@field public hovered_url? string "The path that is currently hovered over in this yazi."
---@field public cwd? string "The path that the yazi process is currently in."
---@field private config YaziConfig
---@field private yazi_id? string "The YAZI_ID of the yazi process. Can be nil if this feature is not in use."
---@field private ya_process vim.SystemObj
---@field private retries integer
---@field private highlighter YaziSessionHighlighter
local YaProcess = {}
---@diagnostic disable-next-line: inject-field
YaProcess.__index = YaProcess

---@param config YaziConfig
---@param yazi_id string
function YaProcess.new(config, yazi_id)
  local self = setmetatable({}, YaProcess)

  self.yazi_id = yazi_id
  self.config = config
  self.events = {}
  self.retries = 0
  self.highlighter = YaziSessionHighlighter.new()

  return self
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

function YaProcess:kill()
  Log:debug("Killing ya process")
  pcall(self.ya_process.kill, self.ya_process, "sigterm")
  self.highlighter:clear_highlights()
end

function YaProcess:wait(timeout)
  Log:debug("Waiting for ya process to exit")
  self.ya_process:wait(timeout)
  return self.events
end

function YaProcess:start()
  local event_kinds = {
    "rename",
    "delete",
    "trash",
    "move",
    "cd",
    "hover",
    "bulk",
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
            self:start()
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

      Log:debug(string.format("ya stdout: '%s'", data))

      data = vim.split(data, "\n", { plain = true, trimempty = true })

      local parsed = utils.safe_parse_events(data)
      Log:debug(string.format("Parsed events: %s", vim.inspect(parsed)))

      self:process_events(parsed, interesting_events)
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
function YaProcess:process_events(events, forwarded_event_kinds)
  for _, event in ipairs(events) do
    if event.type == "hover" then
      ---@cast event YaziHoverEvent
      if event.yazi_id == self.yazi_id then
        Log:debug(
          string.format("Changing the last hovered_url to %s", event.url)
        )
        self.hovered_url = event.url
      end
      vim.schedule(function()
        self.highlighter:highlight_buffers_when_hovered(event.url, self.config)

        local event_handling =
          require("yazi.event_handling.nvim_event_handling")
        event_handling.emit("YaziDDSHover", event)
      end)
    elseif event.type == "cd" then
      ---@cast event YaziHoverEvent
      Log:debug(
        string.format("Changing the cwd from %s to %s", self.cwd, event.url)
      )
      self.cwd = event.url
    else
      if not self.config.future_features.process_events_live then
        -- these events will be processed when yazi exits
        self.events[#self.events + 1] = event
      end

      if
        event.type == "rename"
        or event.type == "move"
        or event.type == "bulk"
      then
        vim.schedule(function()
          local success, result = pcall(function()
            require("yazi.event_handling.nvim_event_handling").emit_renamed_or_moved_event(
              event
            )
          end)
          if not success then
            Log:debug(vim.inspect({
              "Failed to emit YaziRenamedOrMoved event",
              event,
              result,
            }))
          end

          if self.config.future_features.process_events_live == true then
            require("yazi.event_handling.yazi_event_handling").process_events_emitted_from_yazi(
              events
            )
          end
        end)
      elseif forwarded_event_kinds[event.type] ~= nil then
        vim.schedule(function()
          require("yazi.event_handling.nvim_event_handling").emit(
            "YaziDDSCustom",
            event
          )
        end)
      else
        if self.config.future_features.process_events_live == true then
          vim.schedule(function()
            require("yazi.event_handling.yazi_event_handling").process_events_emitted_from_yazi(
              events
            )
          end)
        else
          Log:debug(
            string.format("Ignoring unknown event: %s", vim.inspect(event))
          )
        end
      end
    end
  end
end

return YaProcess
