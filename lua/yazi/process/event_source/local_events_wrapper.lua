-- A tiny wrapper program that is executed with `nvim -l` (Neovim as a plain
-- Lua interpreter, ~20ms of startup and no user config loaded).
--
-- Why does this exist? Read documentation/reading-events-from-yazi.md
--
-- Usage: nvim -l local_events_wrapper.lua <port> <token> <yazi> [args...]

local uv = vim.uv or vim.loop

-- `arg` is only set when Neovim is run as `nvim -l`.
-- selene: allow(global_usage)
local argv = _G.arg

-- When this file is `require()`d as an ordinary module (a stray require,
-- :checkhealth, a documentation generator) there is nothing to do.
if argv == nil or argv[1] == nil then
  return {}
end

---The terminal belongs to yazi, and stdout is the event stream, so problems
---can only be reported on stderr.
---@param message string
local function warn(message)
  -- selene: allow(incorrect_standard_library_use)
  io.stderr:write(message)
end

local port = tonumber(argv[1])
local token = argv[2]
local yazi_executable = argv[3]

local yazi_args = {}
for i = 4, #argv do
  yazi_args[#yazi_args + 1] = argv[i]
end

if port == nil or token == nil or yazi_executable == nil then
  warn("yazi.nvim: local_events_wrapper.lua called with bad args\n")
  os.exit(1)
end

---Bytes yazi produced before the socket finished connecting. Buffering them
---means the events yazi reports during its own startup are not lost, which is
---the entire point of this program.
---@type string[]
local pending = {}
local connected = false

local socket = uv.new_tcp()

---Give up on reporting events. yazi itself keeps running - the user gets a
---working file manager, just without the Neovim integration, which is far
---better than killing their editor's terminal.
local function abandon_socket()
  pending = {}
  connected = false
  if socket ~= nil and not socket:is_closing() then
    socket:close()
  end
  socket = nil
end

---@param data string
local function forward(data)
  local connection = socket
  if connection == nil then
    return
  elseif not connected then
    pending[#pending + 1] = data
    return
  end

  local ok = pcall(connection.write, connection, data)
  if not ok then
    abandon_socket()
  end
end

if socket == nil then
  -- yazi will still run, just without telling Neovim what happens in it
  warn("yazi.nvim: could not create the event socket\n")
else
  socket:connect("127.0.0.1", port, function(err)
    local connection = socket
    if err ~= nil or connection == nil then
      abandon_socket()
      return
    end

    connected = true
    -- The first line proves to yazi.nvim that we are the wrapper it started,
    -- and not some other local process that guessed the port.
    local buffered = table.concat(pending)
    pending = {}
    local ok = pcall(connection.write, connection, token .. "\n" .. buffered)
    if not ok then
      abandon_socket()
    end
  end)
end

local stdout = assert(uv.new_pipe(false), "could not create a stdout pipe")

local yazi_exited = false
local stdout_closed = false
local exit_code = 0

local function finish()
  if not (yazi_exited and stdout_closed) then
    return
  end

  if socket ~= nil and not socket:is_closing() then
    socket:shutdown(function()
      abandon_socket()
      uv.stop()
    end)
  else
    uv.stop()
  end
end

-- Start yazi immediately rather than waiting for the socket to connect, so the
-- wrapper adds no perceptible delay to how fast yazi appears.
local handle, spawn_error = uv.spawn(yazi_executable, {
  args = yazi_args,
  -- stdin and stderr are inherited from the terminal Neovim gave us. yazi
  -- opens the controlling terminal itself for drawing, so it is unaffected by
  -- stdout being a pipe.
  stdio = { 0, stdout, 2 },
}, function(code)
  exit_code = code or 0
  yazi_exited = true
  finish()
end)

if handle == nil then
  warn(
    string.format(
      "yazi.nvim: failed to start '%s': %s\n",
      yazi_executable,
      tostring(spawn_error)
    )
  )
  os.exit(1)
end

stdout:read_start(function(err, data)
  if err ~= nil or data == nil then
    -- read error, or end of stream because yazi closed its stdout
    if not stdout:is_closing() then
      stdout:close()
    end
    stdout_closed = true
    finish()
    return
  end

  forward(data)
end)

-- Neovim terminates the terminal job by signalling this process. Pass that on
-- to yazi so it can restore the terminal and write its chooser/cwd files,
-- instead of being orphaned.
for _, name in ipairs({ "sigterm", "sighup", "sigint" }) do
  local signal = uv.new_signal()
  if signal ~= nil then
    signal:start(name, function()
      pcall(handle.kill, handle, name)
    end)
    -- do not let a pending signal handle keep the event loop alive
    signal:unref()
  end
end

uv.run()
os.exit(exit_code)
