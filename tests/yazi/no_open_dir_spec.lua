local assert = require('luassert')
local mock = require('luassert.mock')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('when the user set open_for_directories = false', function()
  after_each(function()
    mock.clear(api_mock)
  end)

  before_each(function()
    plugin.setup({ open_for_directories = false })
  end)

  it('does not show yazi when a directory is opened', function()
    vim.api.nvim_command('edit /')
    assert.stub(api_mock.termopen).was_not_called()
  end)
end)
