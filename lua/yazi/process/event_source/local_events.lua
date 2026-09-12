local Log = require("yazi.log")
local event_source = require("yazi.process.event_source")

--- A source that reads events from yazi's stdout directly. Because of nvim
--- limitations with reading stdout from an interactive terminal application
--- (yazi), a small wrapper program is used to forward yazi's stdout over a TCP
--- socket.
---
---@class yazi.LocalEventsSource : yazi.EventSource
---@field private config YaziConfig
---@field private yazi_id string
---@field private server? yazi.LocalEventServer
local LocalEventsSource = {}
LocalEventsSource.__index = LocalEventsSource

---Path to the wrapper program that `nvim -l` runs.
---@return string
local function wrapper_script_path()
  local this_file = debug.getinfo(1, "S").source:sub(2)
  return vim.fs.joinpath(
    vim.fn.fnamemodify(this_file, ":h"),
    "local_events_wrapper.lua"
  )
end

---@param config YaziConfig
---@param yazi_id string
---@return yazi.LocalEventsSource
function LocalEventsSource.new(config, yazi_id)
  local self = setmetatable({}, LocalEventsSource)

  self.name = "yazi --local-events"
  self.config = config
  self.yazi_id = yazi_id

  return self
end

---@param on_lines fun(lines: string[])
---@return boolean, string?
function LocalEventsSource:open(on_lines)
  local LocalEventServer =
    require("yazi.process.event_source.local_events_server")

  local server, error_message = LocalEventServer.start(on_lines)
  if server == nil then
    return false, error_message
  end

  self.server = server
  return true, nil
end

---@return string[]
function LocalEventsSource:yazi_arguments()
  -- ask yazi to report its own events to its stdout, which the wrapper pipes
  -- back to us. This replaces `ya sub`.
  local event_kinds = event_source.event_kinds(self.config)
  return { "--local-events=" .. table.concat(event_kinds, ",") }
end

--- Run the wrapper in the terminal, with yazi as its child, so that yazi's
--- stdout can be read while yazi is running.
---@param yazi_command string[]
---@return string[]
function LocalEventsSource:terminal_command(yazi_command)
  local server = assert(self.server, "the event source has not been opened")

  local command = vim.list_slice(yazi_command)
  local yazi_executable = table.remove(command, 1)

  return vim.list_extend({
    vim.v.progpath,
    "-l",
    wrapper_script_path(),
    tostring(server.port),
    server:get_token(),
    yazi_executable,
  }, command)
end

---@return table<string, string>
function LocalEventsSource:environment()
  return {
    -- tell the `nvim.yazi` plugin to publish its events locally (so they end
    -- up on yazi's stdout) instead of broadcasting them to remote peers
    YAZI_NVIM_LOCAL_EVENTS = "1",
  }
end

---@return boolean
function LocalEventsSource:is_listening()
  return self.server ~= nil
end

---Receiving anything at all proves yazi is running and reporting events, so it
---takes the place of the `hey` handshake that `ya sub` relies on.
---@param _event YaziEvent
---@return boolean
---@diagnostic disable-next-line: unused-local
function LocalEventsSource:is_ready_signal(_event)
  assert(self.server ~= nil, "the event source has not been opened")
  return true
end

function LocalEventsSource:start()
  -- the server is already listening; yazi's own stdout is the transport, so
  -- there is no second process to start
  Log:debug("Reading events from yazi's stdout, not starting `ya sub`")
end

---@param _timeout integer
---@diagnostic disable-next-line: unused-local
function LocalEventsSource:close(_timeout)
  if self.server == nil then
    return
  end

  self.server:close()
  self.server = nil
end

return LocalEventsSource
