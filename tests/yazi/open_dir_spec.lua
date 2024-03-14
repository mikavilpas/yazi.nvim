local assert = require('luassert')
local mock = require('luassert.mock')
local match = require('luassert.match')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('when the user set open_for_directories = true', function()
  before_each(function()
    -- add default options that are set in ../../plugin/yazi.vim
    vim.g.yazi_floating_window_winblend = 0
    vim.g.yazi_floating_window_scaling_factor = 0.9

    plugin.setup({ open_for_directories = true })
  end)

  after_each(function()
    mock.clear(api_mock)
  end)

  it('shows yazi when a directory is opened', function()
    -- instead of netrw opening, yazi should open
    vim.api.nvim_command('edit /')

    assert
      .stub(api_mock.termopen)
      .was_called_with('yazi "/" --chooser-file "/tmp/yazi_filechosen"', match.is_table())
  end)
end)
