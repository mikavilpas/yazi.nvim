local assert = require("luassert")
local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")
local reset = require("spec.yazi.helpers.reset")

describe("get_buffers_that_need_renaming_after_yazi_exited", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  it("can detect moves to files whose names match exactly", function()
    ---@type YaziEventDataRenameOrMove
    local move_event = {
      from = "/my-tmp/file1",
      to = "/my-tmp/file2",
    }

    -- simulate buffers being opened
    vim.fn.bufadd("/my-tmp/file1")
    vim.fn.bufadd("/my-tmp/file_A")

    local instructions =
      yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        move_event
      )

    assert.is_equal(vim.tbl_count(instructions), 1)

    local result1 = instructions[1]
    assert.is_equal("/my-tmp/file2", result1.path.filename)
    assert.is_number(result1.bufnr)
  end)

  it(
    "can detect moves to buffers open in a directory that was moved",
    function()
      ---@type YaziEventDataRenameOrMove
      local move_event = {
        from = "/my-tmp/dir1",
        to = "/my-tmp/dir2",
      }

      -- simulate the buffer being opened
      vim.fn.bufadd("/my-tmp/dir1/file")

      local instructions =
        yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
          move_event
        )

      assert.is_equal(vim.tbl_count(instructions), 1)
      local result = instructions[1]
      assert.is_equal("/my-tmp/dir2/file", result.path.filename)
    end
  )

  it("doesn't move a buffer that was not moved in yazi", function()
    ---@type YaziEventDataRenameOrMove
    local move_event = {
      from = "/my-tmp/not-opened-file",
      to = "/my-tmp/not-opened-file-moved",
    }

    -- simulate the buffer being opened
    vim.fn.bufadd("/my-tmp/dir1/file")

    local instructions =
      yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        move_event
      )

    assert.is_equal(vim.tbl_count(instructions), 0)
  end)
end)
