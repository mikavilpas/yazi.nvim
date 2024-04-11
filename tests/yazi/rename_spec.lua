local assert = require('luassert')
local event_handling = require('yazi.event_handling')

describe('get_buffers_that_need_renaming_after_yazi_exited', function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it('can detect renames to files whose names match exactly', function()
    ---@type YaziEventDataRename
    local rename_event = {
      from = '/my-tmp/file1',
      to = '/my-tmp/file2',
    }

    -- simulate buffers being opened
    vim.fn.bufadd('/my-tmp/file1')
    vim.fn.bufadd('/my-tmp/file_A')

    local rename_instructions =
      event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        rename_event
      )

    assert.is_equal(vim.tbl_count(rename_instructions), 1)

    local result1 = rename_instructions[1]
    assert.is_equal('/my-tmp/file2', result1.path.filename)
    assert.is_number(result1.bufnr)
  end)

  it(
    'can detect renames to buffers open in a directory that was renamed',
    function()
      ---@type YaziEventDataRename
      local rename_event = {
        from = '/my-tmp/dir1',
        to = '/my-tmp/dir2',
      }

      -- simulate the buffer being opened
      vim.fn.bufadd('/my-tmp/dir1/file')

      local rename_instructions =
        event_handling.get_buffers_that_need_renaming_after_yazi_exited(
          rename_event
        )

      assert.is_equal(vim.tbl_count(rename_instructions), 1)
      local result = rename_instructions[1]
      assert.is_equal('/my-tmp/dir2/file', result.path.filename)
    end
  )

  it("doesn't rename a buffer that was not renamed in yazi", function()
    ---@type YaziEventDataRename
    local rename_event = {
      from = '/my-tmp/not-opened-file',
      to = '/my-tmp/not-opened-file-renamed',
    }

    -- simulate the buffer being opened
    vim.fn.bufadd('/my-tmp/dir1/file')

    local rename_instructions =
      event_handling.get_buffers_that_need_renaming_after_yazi_exited(
        rename_event
      )

    assert.is_equal(vim.tbl_count(rename_instructions), 0)
  end)
end)
