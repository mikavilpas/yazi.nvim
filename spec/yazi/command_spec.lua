local assert = require("luassert")
local commands = require("yazi.commands")
local stub = require("luassert.stub")
local yazi = require("yazi")
local yazi_log = require("yazi.log")

local home = vim.fn.expand("$HOME")

describe("the Yazi commands", function()
  local snapshot
  local yazi_stub
  local yazi_toggle_stub
  local yazi_logs_stub
  local fake_log_file_path = home .. "/fake-yazi-log.log"

  before_each(function()
    snapshot = assert:snapshot()

    yazi_stub = stub(yazi, "yazi")
    yazi_toggle_stub = stub(yazi, "toggle")
    yazi_logs_stub = stub(yazi_log, "get_logfile_path", function()
      return fake_log_file_path
    end)

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

  it("creates the `:Yazi logs` command", function()
    commands.create_yazi_commands()
    vim.cmd(":Yazi logs")

    assert.stub(yazi_logs_stub).called(1)

    -- make sure the log file is open
    local buffers = vim.api.nvim_list_bufs()
    assert.equal(1, #buffers)
    assert.equal(fake_log_file_path, vim.api.nvim_buf_get_name(buffers[1]))
  end)
end)
