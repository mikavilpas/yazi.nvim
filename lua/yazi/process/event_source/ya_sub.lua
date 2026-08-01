local Log = require("yazi.log")
local event_source = require("yazi.process.event_source")
local utils = require("yazi.utils")

--- Reads yazi's events from a separate `ya sub` process, which connects to the
--- running yazi over DDS.
---
--- `ya sub` can only connect *after* yazi has started, and it retries once a
--- second, so events that happen before it connects are never delivered.
---
---@class yazi.YaSubEventSource : yazi.EventSource
---@field private config YaziConfig
---@field private yazi_id string
---@field private on_lines fun(lines: string[])
---@field private ya_process? vim.SystemObj
---@field private retries integer
local YaSubEventSource = {}
YaSubEventSource.__index = YaSubEventSource

---@param config YaziConfig
---@param yazi_id string
---@return yazi.YaSubEventSource
function YaSubEventSource.new(config, yazi_id)
  local self = setmetatable({}, YaSubEventSource)

  self.name = "ya-sub"
  self.config = config
  self.yazi_id = yazi_id
  self.retries = 0

  return self
end

---@param on_lines fun(lines: string[])
---@return boolean, string?
function YaSubEventSource:open(on_lines)
  -- nothing to acquire: `ya sub` is started once yazi is running
  self.on_lines = on_lines
  return true, nil
end

---@return string[]
function YaSubEventSource:yazi_arguments()
  return {}
end

---@param yazi_command string[]
---@return string[]
function YaSubEventSource:terminal_command(yazi_command)
  return yazi_command
end

---@return table<string, string>
function YaSubEventSource:environment()
  return {}
end

---@return boolean
function YaSubEventSource:is_listening()
  return self.ya_process ~= nil
end

---@return string
function YaSubEventSource:id()
  return self.yazi_id
    .. "-"
    .. (self.ya_process and self.ya_process.pid or "nil")
end

---When ya starts, it will send a "hi" event to all yazis. They respond with
---"hey" to acknowledge this. We use this to detect when ya is ready, so that
---integration-tests can safely start.
---
---The `hey` handshake is sent by whichever instance acts as the DDS server (it
---might be a different yazi than what yazi.nvim starts), so `event.yazi_id`
---(the sender) is not necessarily our yazi. Instead, detect the readiness of
---our yazi by looking for its client-id in the peer list. This is robust even
---when other yazi instances are running on the system.
---@param event YaziEvent
---@return boolean
function YaSubEventSource:is_ready_signal(event)
  if event.type ~= "hey" then
    return false
  end

  ---@cast event YaziRawHeyEvent
  return utils.parse_hey_peers(event.raw_data)[self.yazi_id] == true
end

function YaSubEventSource:start()
  local event_kinds = event_source.event_kinds(self.config)
  table.insert(event_kinds, "hey")

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

      if not data:match("^hey") then
        Log:debug(string.format("ya stdout: '%s'", data))
      end

      self.on_lines(vim.split(data, "\n", { plain = true, trimempty = true }))
    end,

    ---@param obj vim.SystemCompleted
    on_exit = function(obj)
      Log:debug(string.format("ya process exited with code: %s", obj.code))
    end,
  })
end

---@param timeout integer
function YaSubEventSource:close(timeout)
  if self.ya_process == nil then
    return
  end

  Log:debug("Killing ya process")
  pcall(self.ya_process.kill, self.ya_process, "sigterm")

  Log:debug("Waiting for ya process to exit")
  self.ya_process:wait(timeout)
  self.ya_process = nil
end

return YaSubEventSource
