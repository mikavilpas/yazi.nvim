local assert = require("luassert")
local stub = require("luassert.stub")
local LocalEventServer =
  require("yazi.process.event_source.local_events_server")

---Connect to the server the way `local_events_wrapper.lua` does, and wait
---until the connection is established.
---@param port integer
---@return uv.uv_tcp_t
local function connect(port)
  local client = assert(vim.uv.new_tcp())
  local connected = false
  client:connect("127.0.0.1", port, function(err)
    assert(err == nil, tostring(err))
    connected = true
  end)
  assert(
    vim.wait(2000, function()
      return connected
    end),
    "timed out connecting to the local event server"
  )
  return client
end

---@param received string[][]
---@param count integer
---@param timeout? integer # keep it short when asserting that nothing arrives
local function wait_for_batches(received, count, timeout)
  return vim.wait(timeout or 2000, function()
    return #received >= count
  end)
end

describe("the local event server", function()
  ---@type yazi.LocalEventServer | nil
  local server = nil

  after_each(function()
    if server ~= nil then
      server:close()
      server = nil
    end
  end)

  it("reports why it could not be started", function()
    -- libuv reports failures by returning nil plus a message. Make sure the
    -- message is not swallowed, so that the fallback to `ya sub` can say why it
    -- happened.
    stub(vim.uv, "new_tcp", nil, "EMFILE: too many open files", "EMFILE")

    local created, reason = LocalEventServer.start(function() end)

    ---@diagnostic disable-next-line: undefined-field
    vim.uv.new_tcp:revert()

    assert.is_nil(created)
    assert.is_not_nil(reason)
    assert.is_truthy(
      reason and reason:find("EMFILE: too many open files", 1, true),
      string.format("expected the libuv reason in '%s'", tostring(reason))
    )
  end)

  it("listens on a port on the loopback interface", function()
    local created, reason = LocalEventServer.start(function() end)
    server = created

    assert.is_nil(reason)
    assert.is_not_nil(server)
    assert.is_true(server ~= nil and server.port > 0)
  end)

  it("hands over complete lines from a client that knows the token", function()
    ---@type string[][]
    local received = {}
    local created = assert(LocalEventServer.start(function(lines)
      received[#received + 1] = lines
    end))
    server = created

    local client = connect(created.port)
    client:write(created:get_token() .. "\n")
    client:write('cd,1,1,{"tab":1}\nhover,1,1,{"tab":1}\n')

    assert.is_true(wait_for_batches(received, 1))
    assert.are.same({
      { 'cd,1,1,{"tab":1}', 'hover,1,1,{"tab":1}' },
    }, received)

    client:close()
  end)

  it("waits for the rest of a line that arrived in pieces", function()
    -- a TCP read can split an event anywhere, so a partial line must be held
    -- back until its newline arrives
    ---@type string[][]
    local received = {}
    local created = assert(LocalEventServer.start(function(lines)
      received[#received + 1] = lines
    end))
    server = created

    local client = connect(created.port)
    client:write(created:get_token() .. "\n")
    client:write('cd,1,1,{"tab"')

    -- nothing is complete yet, so nothing may be handed over
    assert.is_false(wait_for_batches(received, 1, 200))

    client:write(':1}\ntrash,1,1,{"urls":[]}\n')

    assert.is_true(wait_for_batches(received, 1))
    assert.are.same({
      { 'cd,1,1,{"tab":1}', 'trash,1,1,{"urls":[]}' },
    }, received)

    client:close()
  end)

  it("drops a client that presents the wrong token", function()
    ---@type string[][]
    local received = {}
    local created = assert(LocalEventServer.start(function(lines)
      received[#received + 1] = lines
    end))
    server = created

    local client = connect(created.port)
    client:write("not-the-token\n")
    client:write('cd,1,1,{"tab":1}\n')

    assert.is_false(wait_for_batches(received, 1, 200))
    assert.are.same({}, received)

    if not client:is_closing() then
      client:close()
    end
  end)
end)
