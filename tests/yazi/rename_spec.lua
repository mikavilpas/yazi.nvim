local assert = require('luassert')
local utils = require('yazi.utils')

describe('get_buffers_that_need_renaming_after_yazi_exited', function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it('can detect renames to files whose names match exactly', function()
    ---@type YaziRenameEvent[]
    local rename_events = {
      {
        type = 'rename',
        timestamp = '1712242143209837',
        id = '1712242143209837',
        data = {
          from = '/my-tmp/file1',
          to = '/my-tmp/file2',
        },
      },
      {
        type = 'rename',
        timestamp = '1712242143209837',
        id = '1712242143209837',
        data = {
          from = '/my-tmp/file3',
          to = '/my-tmp/file4',
        },
      },
    }

    -- simulate the buffers being opened
    vim.fn.bufadd('/my-tmp/file1')
    vim.fn.bufadd('/my-tmp/file3')

    local renames =
      utils.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(#renames, 2)

    local result1 = renames[1]
    assert.is_equal('/my-tmp/file2', result1.to)
    assert.is_number(result1.buffer)

    local result2 = renames[2]
    assert.is_equal('/my-tmp/file4', result2.to)
    assert.is_number(result2.buffer)
  end)

  it(
    'can detect renames to buffers open in a directory that was renamed',
    function()
      ---@type YaziRenameEvent[]
      local rename_events = {
        {
          type = 'rename',
          timestamp = '1712242143209837',
          id = '1712242143209837',
          data = {
            from = '/my-tmp/dir1',
            to = '/my-tmp/dir2',
          },
        },
      }

      -- simulate the buffer being opened
      vim.fn.bufadd('/my-tmp/dir1/file')

      local renames =
        utils.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

      assert.is_equal(#renames, 1)

      local result1 = renames[1]
      assert.is_equal('/my-tmp/dir2/file', result1.to)
    end
  )

  it("doesn't rename a buffer that was not renamed in yazi", function()
    ---@type YaziRenameEvent[]
    local rename_events = {
      {
        type = 'rename',
        timestamp = '1712242143209837',
        id = '1712242143209837',
        data = {
          from = '/my-tmp/not-opened-file',
          to = '/my-tmp/not-opened-file-renamed',
        },
      },
    }

    -- simulate the buffer being opened
    vim.fn.bufadd('/my-tmp/dir1/file')

    local renames =
      utils.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(#renames, 0)
  end)
end)
