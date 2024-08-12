local utils = require("yazi.utils")
local assert = require("luassert")

describe("YaziVisibleBuffer", function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end

    -- close all windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      pcall(vim.api.nvim_win_close, win, true)
    end
  end)

  it("is found for a visible buffer editing a file", function()
    vim.cmd("edit file1")
    vim.fn.bufadd("/YaziVisibleBuffer/file1")

    local visible_open_buffers = utils.get_visible_open_buffers()

    assert.equals(1, #visible_open_buffers)
  end)

  it("is not found for a buffer that's not visible", function()
    vim.cmd("edit file1")
    vim.fn.bufadd("/YaziVisibleBuffer/file2")

    local visible_open_buffers = utils.get_visible_open_buffers()

    assert.equals(1, #visible_open_buffers)
    local visible_open_buffer = visible_open_buffers[1]

    assert.equals(
      "file1",
      visible_open_buffer.renameable_buffer.path.filename:match("file1")
    )
  end)
end)
