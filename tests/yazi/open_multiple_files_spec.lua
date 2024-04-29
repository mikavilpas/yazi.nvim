describe('the default configuration', function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it('can display multiple files in the quickfix list', function()
    local config = require('yazi.config').default()
    -- include problematic characters in the file names to preserve their behaviour
    local chosen_files = { '/abc/test-$@file.txt', '/abc/test-file2.txt' }

    config.hooks.yazi_opened_multiple_files(chosen_files, config)

    local quickfix_list = vim.fn.getqflist()

    assert.equals(2, #quickfix_list)
    assert.equals('/abc/test-$@file.txt', quickfix_list[1].text)
    assert.equals('/abc/test-file2.txt', quickfix_list[2].text)
  end)
end)
