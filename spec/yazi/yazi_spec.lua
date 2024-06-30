local assert = require('luassert')
local mock = require('luassert.mock')
local match = require('luassert.match')
local spy = require('luassert.spy')

local api_mock = mock(require('yazi.vimfn'))

local plugin = require('yazi')

describe('opening a file', function()
  after_each(function()
    mock.clear(api_mock)
  end)

  local termopen = spy.on(api_mock, 'termopen')

  before_each(function()
    mock.clear(termopen)
    plugin.setup({})
  end)

  ---@param target_file string
  local function setup_fake_yazi_opens_file(target_file)
    -- have to start editing a valid file, otherwise the plugin will ignore the callback
    vim.cmd('edit /abc/a.txt')

    termopen.callback = function(_, callback)
      -- simulate yazi writing to the output file. This is done when a file is
      -- chosen in yazi
      local exit_code = 0
      vim.fn.writefile({ target_file }, '/tmp/yazi_filechosen')
      callback.on_exit('job-id-ignored', exit_code, 'event-ignored')
      return 0
    end
  end

  it('opens yazi with the current file selected', function()
    -- the file name should have a space as well as special characters, in order to test that
    vim.api.nvim_command('edit ' .. vim.fn.fnameescape('/abc/test file-$1.txt'))
    plugin.yazi({
      chosen_file_path = '/tmp/yazi_filechosen',
      events_file_path = '/tmp/yazi.nvim.events.txt',
    })

    assert.stub(api_mock.termopen).was_called_with(
      'yazi \'/abc/test file-$1.txt\' --local-events "rename,delete,trash,move,cd" --chooser-file "/tmp/yazi_filechosen" > "/tmp/yazi.nvim.events.txt"',
      match.is_table()
    )
  end)

  it('opens yazi with the current directory selected', function()
    vim.api.nvim_command('edit /tmp/')

    plugin.yazi({
      chosen_file_path = '/tmp/yazi_filechosen',
      events_file_path = '/tmp/yazi.nvim.events.txt',
    })

    assert.stub(api_mock.termopen).was_called_with(
      'yazi \'/tmp/\' --local-events "rename,delete,trash,move,cd" --chooser-file "/tmp/yazi_filechosen" > "/tmp/yazi.nvim.events.txt"',
      match.is_table()
    )
  end)

  describe("when a file is selected in yazi's chooser", function()
    it('can open files with complex characters in their name', function()
      -- the filename contains a '$' character which can be problematic to nvim
      local target_file = 'routes/posts.$postId/route.tsx'
      setup_fake_yazi_opens_file(target_file)

      plugin.yazi({
        chosen_file_path = '/tmp/yazi_filechosen',
        set_keymappings_function = function() end,
      })

      assert.equals(target_file, vim.fn.expand('%'))
    end)
  end)

  it(
    "calls the yazi_closed_successfully hook when a file is selected in yazi's chooser",
    function()
      local target_file = '/abc/test-file-potato.txt'
      setup_fake_yazi_opens_file(target_file)
      ---@param state YaziClosedState
      local spy_hook = spy.new(function(chosen_file, _config, state)
        assert.equals('/abc/test-file-potato.txt', chosen_file)
        assert.equals('/abc', state.last_directory.filename)
      end)

      vim.api.nvim_command('edit /abc/test-file.txt')

      plugin.yazi({
        chosen_file_path = '/tmp/yazi_filechosen',
        set_keymappings_function = function() end,
        ---@diagnostic disable-next-line: missing-fields
        hooks = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          yazi_closed_successfully = spy_hook,
        },
      })

      assert
        .spy(spy_hook)
        .was_called_with('/abc/test-file-potato.txt', match.is_table(), match.is_table())
    end
  )

  it('calls the yazi_opened hook when yazi is opened', function()
    local spy_yazi_opened_hook = spy.new()

    vim.api.nvim_command('edit /abc/yazi_opened_hook_file.txt')

    plugin.yazi({
      set_keymappings_function = function() end,
      ---@diagnostic disable-next-line: missing-fields
      hooks = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        yazi_opened = spy_yazi_opened_hook,
      },
    })

    assert
      .spy(spy_yazi_opened_hook)
      .was_called_with('/abc/yazi_opened_hook_file.txt', match.is_number(), match.is_table())
  end)

  it('calls the open_file_function to open the selected file', function()
    local target_file = '/abc/test-file-lnotial.txt'
    setup_fake_yazi_opens_file(target_file)
    local spy_open_file_function = spy.new()

    vim.api.nvim_command('edit ' .. target_file)

    plugin.yazi({
      chosen_file_path = '/tmp/yazi_filechosen',
      set_keymappings_function = function() end,
      ---@diagnostic disable-next-line: assign-type-mismatch
      open_file_function = spy_open_file_function,
    })

    assert
      .spy(spy_open_file_function)
      .was_called_with(target_file, match.is_table(), match.is_table())
  end)
end)

describe('opening multiple files', function()
  local target_file_1 = '/abc/test-file-multiple-1.txt'
  local target_file_2 = '/abc/test-file-multiple-2.txt'

  before_each(function()
    local termopen = spy.on(api_mock, 'termopen')
    termopen.callback = function(_, callback)
      -- simulate yazi writing to the output file. This is done when a file is
      -- chosen in yazi
      local exit_code = 0
      vim.fn.writefile({
        target_file_1,
        target_file_2,
      }, '/tmp/yazi_filechosen-123')
      callback.on_exit('job-id-ignored', exit_code, 'event-ignored')
    end
  end)

  it('can open multiple files', function()
    local spy_open_multiple_files = spy.new()
    plugin.yazi({
      set_keymappings_function = function() end,
      ---@diagnostic disable-next-line: missing-fields
      hooks = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        yazi_opened_multiple_files = spy_open_multiple_files,
      },
      chosen_file_path = '/tmp/yazi_filechosen-123',
    })

    assert.spy(spy_open_multiple_files).was_called_with({
      target_file_1,
      target_file_2,
    }, match.is_table(), match.is_table())
  end)
end)
