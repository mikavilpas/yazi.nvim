local assert = require("luassert")
local commands = require("yazi.commands")
local stub = require("luassert.stub")
local yazi = require("yazi")

describe("the Yazi commands", function()
  local snapshot
  local yazi_stub
  local yazi_toggle_stub

  before_each(function()
    snapshot = assert:snapshot()

    yazi_stub = stub(yazi, "yazi")
    yazi_toggle_stub = stub(yazi, "toggle")

    stub(vim.fn, "getcwd", function()
      return "/tmp"
    end)
  end)

  after_each(function()
    snapshot:revert()
  end)

  it("creates the `:Yazi` command", function()
    commands.create_yazi_commands()
    vim.cmd(":Yazi")

    assert.stub(yazi_stub).called_with()
  end)

  it("creates the `:Yazi cwd` command", function()
    commands.create_yazi_commands()
    vim.cmd(":Yazi cwd")

    assert.stub(yazi_stub).called_with(nil, "/tmp")
  end)

  it("creates the `:Yazi toggle` command", function()
    commands.create_yazi_commands()
    vim.cmd(":Yazi toggle")

    assert.stub(yazi_toggle_stub).called_with()
  end)
end)
