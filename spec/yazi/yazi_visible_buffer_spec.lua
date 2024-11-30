local utils = require("yazi.utils")
local assert = require("luassert")
local reset = require("spec.yazi.helpers.reset")

describe("YaziVisibleBuffer", function()
  before_each(function()
    reset.clear_all_buffers()
    reset.close_all_windows()
  end)

  it("is found for a visible buffer editing a file", function()
    vim.cmd("edit file1")
    vim.fn.bufadd("/YaziVisibleBuffer/file1")

    local visible_open_buffers = utils.get_visible_open_buffers()

    assert.equal(1, #visible_open_buffers)
  end)

  it("is not found for a buffer that's not visible", function()
    vim.cmd("edit file1")
    vim.fn.bufadd("/YaziVisibleBuffer/file2")

    local visible_open_buffers = utils.get_visible_open_buffers()

    assert.equal(1, #visible_open_buffers)
    local visible_open_buffer = visible_open_buffers[1]

    assert.equal(
      "file1",
      visible_open_buffer.renameable_buffer.path.filename:match("file1")
    )
  end)
end)
