local assert = require('luassert')
local mock = require('luassert.mock')
local match = require('luassert.match')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('when the user set open_for_directories = true', function()
  before_each(function()
    ---@diagnostic disable-next-line: missing-fields
    plugin.setup({
      open_for_directories = true,
      chosen_file_path = '/tmp/yazi_filechosen',
      events_file_path = '/tmp/yazi.nvim.events.txt',
    })
  end)

  after_each(function()
    mock.clear(api_mock)
  end)

  it('shows yazi when a directory is opened', function()
    -- instead of netrw opening, yazi should open
    vim.api.nvim_command('edit /')

    assert.stub(api_mock.termopen).was_called_with(
      'yazi "/" --local-events "rename,delete,trash,move" --chooser-file "/tmp/yazi_filechosen" > "/tmp/yazi.nvim.events.txt"',
      match.is_table()
    )
  end)
end)
