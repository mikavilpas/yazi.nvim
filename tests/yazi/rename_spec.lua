local assert = require('luassert')
local renaming = require('yazi.renaming')

describe('get_buffers_that_need_renaming_after_yazi_exited', function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it('can detect renames to files whose names match exactly', function()
    ---@type YaziEventDataRename[]
    local rename_events = {
      {
        from = '/my-tmp/file1',
        to = '/my-tmp/file2',
      },
      {
        from = '/my-tmp/file_A',
        to = '/my-tmp/file_B',
      },
    }

    -- simulate the buffers being opened
    vim.fn.bufadd('/my-tmp/file1')
    vim.fn.bufadd('/my-tmp/file_A')

    local rename_instructions =
      renaming.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(vim.tbl_count(rename_instructions), 2)

    local result1 = rename_instructions[1]
    assert.is_equal('/my-tmp/file2', result1.path.filename)
    assert.is_number(result1.bufnr)

    local result2 = rename_instructions[2]
    assert.is_equal('/my-tmp/file_B', result2.path.filename)
    assert.is_number(result2.bufnr)
  end)

  it(
    'can detect renames to buffers open in a directory that was renamed',
    function()
      ---@type YaziEventDataRename[]
      local rename_events = {
        {
          from = '/my-tmp/dir1',
          to = '/my-tmp/dir2',
        },
      }

      -- simulate the buffer being opened
      vim.fn.bufadd('/my-tmp/dir1/file')

      local rename_instructions =
        renaming.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

      assert.is_equal(vim.tbl_count(rename_instructions), 1)
      local result = rename_instructions[1]
      assert.is_equal('/my-tmp/dir2/file', result.path.filename)
    end
  )

  it("doesn't rename a buffer that was not renamed in yazi", function()
    ---@type YaziEventDataRename[]
    local rename_events = {
      {
        from = '/my-tmp/not-opened-file',
        to = '/my-tmp/not-opened-file-renamed',
      },
    }

    -- simulate the buffer being opened
    vim.fn.bufadd('/my-tmp/dir1/file')

    local rename_instructions =
      renaming.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(vim.tbl_count(rename_instructions), 0)
  end)

  it('can rename the same file multiple times', function()
    ---@type YaziEventDataRename[]
    local rename_events = {
      {
        from = '/my-tmp/file1',
        to = '/my-tmp/file2',
      },
      {
        from = '/my-tmp/file2',
        to = '/my-tmp/file3',
      },
    }

    -- simulate the buffers being opened
    vim.fn.bufadd('/my-tmp/file1')

    local rename_instructions =
      renaming.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(vim.tbl_count(rename_instructions), 1)

    local result = rename_instructions[1]
    assert.is_equal('/my-tmp/file3', result.path.filename)
    assert.is_number(result.bufnr)
  end)

  it('can rename the same directory multiple times', function()
    ---@type YaziEventDataRename[]
    local rename_events = {
      {
        from = '/my-tmp/dir1',
        to = '/my-tmp/dir2',
      },
      {
        from = '/my-tmp/dir2',
        to = '/my-tmp/dir3',
      },
    }

    -- simulate the buffer being opened
    vim.fn.bufadd('/my-tmp/dir1/file')

    local rename_instructions =
      renaming.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

    assert.is_equal(vim.tbl_count(rename_instructions), 1)
    local result = rename_instructions[1]
    assert.is_equal('/my-tmp/dir3/file', result.path.filename)
  end)
end)
