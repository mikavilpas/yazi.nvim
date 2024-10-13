local assert = require("luassert")
local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")
local utils = require("yazi.utils")
local reset = require("spec.yazi.helpers.reset")

describe("get_buffers_that_need_renaming_after_yazi_exited", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  it("can detect renames to files whose names match exactly", function()
    ---@type YaziEventDataRenameOrMove
    local rename_event = {
      from = "/my-tmp/file1",
      to = "/my-tmp/file2",
    }

    -- simulate buffers being opened
    vim.fn.bufadd("/my-tmp/file1")
    vim.fn.bufadd("/my-tmp/file_A")

    local rename_instructions =
      yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        rename_event
      )

    assert.is_equal(vim.tbl_count(rename_instructions), 1)

    local result1 = rename_instructions[1]
    assert.is_equal("/my-tmp/file2", result1.path.filename)
    assert.is_number(result1.bufnr)
  end)

  it(
    "can detect renames to buffers open in a directory that was renamed",
    function()
      ---@type YaziEventDataRenameOrMove
      local rename_event = {
        from = "/my-tmp/dir1",
        to = "/my-tmp/dir2",
      }

      -- simulate the buffer being opened
      vim.fn.bufadd("/my-tmp/dir1/file")

      local rename_instructions =
        yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
          rename_event
        )

      assert.is_equal(vim.tbl_count(rename_instructions), 1)
      local result = rename_instructions[1]
      assert.is_equal("/my-tmp/dir2/file", result.path.filename)
    end
  )

  it("doesn't rename a buffer that was not renamed in yazi", function()
    ---@type YaziEventDataRenameOrMove
    local rename_event = {
      from = "/my-tmp/not-opened-file",
      to = "/my-tmp/not-opened-file-renamed",
    }

    -- simulate the buffer being opened
    vim.fn.bufadd("/my-tmp/dir1/file")

    local rename_instructions =
      yazi_event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        rename_event
      )

    assert.is_equal(vim.tbl_count(rename_instructions), 0)
  end)
end)

describe("process_events_emitted_from_yazi", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  it("closes a buffer that was renamed to another open buffer", function()
    vim.fn.bufadd("/my-tmp/file1")
    vim.fn.bufadd("/my-tmp/file2")

    ---@type YaziRenameEvent
    local event = {
      type = "rename",
      data = {
        from = "/my-tmp/file1",
        to = "/my-tmp/file2",
      },
      timestamp = "2021-09-01T00:00:00Z",
      id = "123",
    }

    yazi_event_handling.process_events_emitted_from_yazi({ event })

    local open_buffers = utils.get_open_buffers()
    for _, buffer in ipairs(open_buffers) do
      assert.is_not_equal("/my-tmp/file1", buffer.path.filename)
    end
  end)

  it("closes a buffer that was moved to another open buffer", function()
    vim.fn.bufadd("/my-tmp/file1")
    vim.fn.bufadd("/my-tmp/file2")

    ---@type YaziMoveEvent
    local event = {
      type = "move",
      id = "123",
      timestamp = "2021-09-01T00:00:00Z",
      data = {
        items = {
          {
            from = "/my-tmp/file1",
            to = "/my-tmp/file2",
          },
        },
      },
    }

    yazi_event_handling.process_events_emitted_from_yazi({ event })

    local open_buffers = utils.get_open_buffers()
    for _, buffer in ipairs(open_buffers) do
      assert.is_not_equal("/my-tmp/file1", buffer.path.filename)
    end
  end)
end)
