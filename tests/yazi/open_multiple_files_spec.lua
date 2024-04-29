describe('the default configuration', function()
  it('can display multiple files in the quickfix list', function()
    local config = require('yazi.config').default()
    local chosen_files = { '/abc/test-file.txt', '/abc/test-file2.txt' }

    config.hooks.yazi_opened_multiple_files(chosen_files, config)

    local quickfix_list = vim.fn.getqflist()

    assert.equals(2, #quickfix_list)
    assert.equals('/abc/test-file.txt', quickfix_list[1].text)
    assert.equals('/abc/test-file2.txt', quickfix_list[2].text)
  end)
end)
