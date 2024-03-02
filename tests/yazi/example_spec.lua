local assert = require('luassert')
local mock = require('luassert.mock')
local match = require('luassert.match')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('setup with no custom options', function()
  before_each(function()
    -- add default options that are set in ../../plugin/yazi.vim
    vim.g.yazi_floating_window_winblend = 0
    vim.g.yazi_floating_window_scaling_factor = 0.9
  end)

  after_each(function()
    mock.clear(api_mock)
  end)

  it('opens yazi with the current file selected', function()
    vim.api.nvim_command('edit ' .. '/tmp/test-file.txt')
    plugin.yazi()

    assert.stub(api_mock.termopen).was_called_with(
      'yazi "/tmp/test-file.txt" --chooser-file "/tmp/yazi_filechosen"',
      match.is_table()
    )
  end)

  it('opens yazi with the current directory selected', function()
    vim.api.nvim_command('edit ' .. '/tmp/')

    plugin.yazi()

    assert
      .stub(api_mock.termopen)
      .was_called_with('yazi "/tmp/" --chooser-file "/tmp/yazi_filechosen"', match.is_table())
  end)
end)
