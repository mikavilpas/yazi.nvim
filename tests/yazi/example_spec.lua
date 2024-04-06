local assert = require('luassert')
local mock = require('luassert.mock')
local match = require('luassert.match')
local spy = require('luassert.spy')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('opening a file', function()
  before_each(function()
    -- add default options that are set in ../../plugin/yazi.vim
    vim.g.yazi_floating_window_winblend = 0
    vim.g.yazi_floating_window_scaling_factor = 0.9
  end)

  after_each(function()
    mock.clear(api_mock)
  end)

  it('opens yazi with the current file selected', function()
    vim.api.nvim_command('edit /abc/test-file.txt')
    plugin.yazi()

    assert.stub(api_mock.termopen).was_called_with(
      'yazi "/abc/test-file.txt" --local-events "rename" --chooser-file "/tmp/yazi_filechosen" > /tmp/yazi.nvim.events.txt',
      match.is_table()
    )
  end)

  it('opens yazi with the current directory selected', function()
    vim.api.nvim_command('edit /tmp/')

    plugin.yazi()

    assert.stub(api_mock.termopen).was_called_with(
      'yazi "/tmp/" --local-events "rename" --chooser-file "/tmp/yazi_filechosen" > /tmp/yazi.nvim.events.txt',
      match.is_table()
    )
  end)

  describe("when a file is selected in yazi's chooser", function()
    -- yazi writes the selected file to this file for us to read
    local target_file = '/abc/test-file.txt'

    before_each(function()
      -- have to start editing a valid file, otherwise the plugin will ignore the callback
      vim.cmd('edit /abc/a.txt')

      local termopen = spy.on(api_mock, 'termopen')
      termopen.callback = function(_, callback)
        -- simulate yazi writing to the output file. This is done when a file is
        -- chosen in yazi
        local exit_code = 0
        vim.fn.writefile({ target_file }, '/tmp/yazi_filechosen')
        callback.on_exit('job-id-ignored', exit_code, 'event-ignored')
      end
    end)

    it('opens the file that the user selected in yazi', function()
      plugin.yazi()

      assert.equals(target_file, vim.fn.expand('%'))
    end)
  end)
end)
