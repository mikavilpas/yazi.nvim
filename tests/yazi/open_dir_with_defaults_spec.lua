local assert = require('luassert')
local mock = require('luassert.mock')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe(
  'when the user has not set open_for_directories and uses the defaults',
  function()
    after_each(function()
      mock.clear(api_mock)
    end)

    it('does not show yazi when a directory is opened', function()
      ---@diagnostic disable-next-line: missing-fields
      plugin.setup()

      -- instead of netrw opening, yazi should open
      vim.api.nvim_command('edit /')

      assert.stub(api_mock.termopen).was_not_called()
    end)
  end
)
