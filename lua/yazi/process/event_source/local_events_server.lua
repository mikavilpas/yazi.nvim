local Log = require("yazi.log")

--- A loopback TCP server that receives the DDS events yazi reports to its
--- stdout. The other end is `local_events_wrapper.lua`, which yazi.nvim starts
--- in the Neovim terminal in place of yazi itself.
---
--- Only complete lines are handed to the callback: a TCP read can split a
--- single event across two chunks, and yazi's event format is line based.
---@class yazi.LocalEventServer
---@field private server uv.uv_tcp_t
---@field private clients uv.uv_tcp_t[]
---@field private token string
---@field public port integer
local LocalEventServer = {}
LocalEventServer.__index = LocalEventServer

---@return string
local function generate_token()
  return string.format("%.0f-%d", vim.uv.hrtime(), math.random(0, 2 ^ 30))
end

---@param on_lines fun(lines: string[]) # called (on the main loop) with each batch of complete event lines
---@return yazi.LocalEventServer | nil, string | nil # the server, or nil and an error message
function LocalEventServer.start(on_lines)
  local self = setmetatable({}, LocalEventServer)
  self.clients = {}
  self.token = generate_token()

  -- libuv reports a failure by returning nil along with a message that already
  -- contains its symbolic name, such as "EADDRINUSE: address already in use"
  local server, new_tcp_error = vim.uv.new_tcp()
  if server == nil then
    return nil,
      string.format(
        "could not create a tcp socket: %s",
        new_tcp_error or "unknown error"
      )
  end
  self.server = server

  -- port 0 means "any free port". Binding to the loopback interface keeps the
  -- socket unreachable from outside this machine; the token check in `accept`
  -- protects against other local processes.
  local bound, bind_error = server:bind("127.0.0.1", 0)
  if bound == nil then
    server:close()
    return nil,
      string.format(
        "could not bind to 127.0.0.1: %s",
        bind_error or "unknown error"
      )
  end

  local listening, listen_error = server:listen(1, function(connection_error)
    if connection_error ~= nil then
      Log:debug(
        string.format(
          "Could not receive a local event connection: %s",
          connection_error
        )
      )
      return
    end
    ---@diagnostic disable-next-line: invisible
    self:accept(on_lines)
  end)
  if listening == nil then
    server:close()
    return nil,
      string.format(
        "could not listen for connections: %s",
        listen_error or "unknown error"
      )
  end

  local name, getsockname_error = server:getsockname()
  if name == nil then
    server:close()
    return nil,
      string.format(
        "could not resolve the port of the local event server: %s",
        getsockname_error or "unknown error"
      )
  end
  if name.port == nil then
    server:close()
    return nil, "the local event server was not given a port"
  end

  self.port = name.port
  Log:debug(
    string.format("Started the local event server on port %s", self.port)
  )

  return self, nil
end

---@return string
function LocalEventServer:get_token()
  return self.token
end

---@private
---@param on_lines fun(lines: string[])
function LocalEventServer:accept(on_lines)
  local client, new_tcp_error = vim.uv.new_tcp()
  if client == nil then
    Log:debug(
      string.format(
        "Could not create a socket for an incoming local event connection: %s",
        new_tcp_error or "unknown error"
      )
    )
    return
  end

  -- note that `accept` reports a failure by returning nil rather than by
  -- raising, so its return value has to be checked
  local accepted, accept_error = self.server:accept(client)
  if accepted == nil then
    Log:debug(
      string.format(
        "Could not accept a local event connection: %s",
        accept_error or "unknown error"
      )
    )
    client:close()
    return
  end

  self.clients[#self.clients + 1] = client

  -- everything received before the token line has been verified
  local buffer = ""
  local authenticated = false

  client:read_start(function(err, chunk)
    if err ~= nil or chunk == nil then
      if not client:is_closing() then
        client:close()
      end
      return
    end

    buffer = buffer .. chunk

    ---@type string[]
    local lines = {}
    while true do
      local newline = buffer:find("\n", 1, true)
      if newline == nil then
        break
      end
      lines[#lines + 1] = buffer:sub(1, newline - 1)
      buffer = buffer:sub(newline + 1)
    end

    if #lines == 0 then
      return
    end

    if not authenticated then
      local presented = table.remove(lines, 1)
      if presented ~= self.token then
        Log:debug(
          "A client connected to the local event server with a bad token, dropping it"
        )
        client:close()
        return
      end
      authenticated = true
      if #lines == 0 then
        return
      end
    end

    vim.schedule(function()
      on_lines(lines)
    end)
  end)
end

function LocalEventServer:close()
  for _, client in ipairs(self.clients) do
    if not client:is_closing() then
      pcall(client.close, client)
    end
  end
  self.clients = {}

  if self.server ~= nil and not self.server:is_closing() then
    pcall(self.server.close, self.server)
  end
end

return LocalEventServer
