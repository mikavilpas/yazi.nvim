local stub = require('luassert.stub')
local assert = require('luassert')
local yazi = require('yazi')

local function assert_buffer_contains_text(needle)
  local buffer_text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(buffer_text, '\n')
  local message = string.format(
    "Expected the main string to contain the substring.\nMain string: '%s'\nSubstring: '%s'",
    text,
    needle
  )

  local found = string.find(text, needle, 1, true) ~= nil
  assert(found, message)
end

-- make nvim find the health check file so that it can be executed by :checkhealth
-- without this, the health check will not be found
vim.opt.rtp:append('.')

local mock_app_versions = {}

describe('the happy path', function()
  local snapshot

  before_each(function()
    snapshot = assert:snapshot()
    mock_app_versions = {
      ['yazi'] = 'yazi 0.2.5 (f5a7ace 2024-06-23)',
      ['ya'] = 'Ya 0.2.5 (f5a7ace 2024-06-23)',
      ['nvim-0.10.0'] = true,
    }

    stub(vim.fn, 'has', function(needle)
      if mock_app_versions[needle] then
        return 1
      else
        return 0
      end
    end)

    stub(vim.fn, 'executable', function(command)
      return mock_app_versions[command] and 1 or 0
    end)

    stub(vim.fn, 'system', function(command)
      if command == 'yazi --version' then
        return mock_app_versions['yazi']
      elseif command == 'ya --version' then
        return mock_app_versions['ya']
      else
        error('unexpected command: ' .. command)
      end
    end)
  end)

  after_each(function()
    snapshot:revert()
  end)

  it('reports everything is ok', function()
    yazi.setup({ use_ya_for_events_reading = true })
    vim.cmd('checkhealth yazi')

    assert_buffer_contains_text('Found `yazi` version `0.2.5`')
    assert_buffer_contains_text('Found `ya` version `0.2.5`')
    assert_buffer_contains_text('OK yazi')
  end)

  it('warns if the yazi version is too old', function()
    mock_app_versions['yazi'] = 'yazi 0.2.4 (f5a7ace 2024-06-23)'
    vim.cmd('checkhealth yazi')

    assert_buffer_contains_text(
      'yazi version is too old, please upgrade to 0.2.5 or newer'
    )
  end)

  it('warns if the ya version is too old', function()
    yazi.setup({ use_ya_for_events_reading = true })
    mock_app_versions['ya'] = 'Ya 0.2.4 (f5a7ace 2024-06-23)'

    vim.cmd('checkhealth yazi')

    assert_buffer_contains_text(
      'WARNING The `ya` executable version (yazi command line interface) is too old.'
    )
  end)

  it('warns when yazi is not found', function()
    mock_app_versions['yazi'] = 'command not found'
  end)

  it('warns when ya is not found', function()
    mock_app_versions['ya'] = 'command not found'

    vim.cmd('checkhealth yazi')

    assert_buffer_contains_text(
      'WARNING `ya --version` looks unexpected, saw `command not found`'
    )
  end)

  it(
    'warns when `ya` cannot be found but is set as the event_reader',
    function()
      stub(vim.fn, 'executable', function(command)
        if command == 'ya' then
          return 0
        else
          return 1
        end
      end)

      require('yazi').setup(
        ---@type YaziConfig
        {
          use_ya_for_events_reading = true,
        }
      )

      vim.cmd('checkhealth yazi')

      assert_buffer_contains_text(
        'ERROR You have opted in to using `ya` for events reading, but `ya` is not found on PATH.'
      )
    end
  )
end)
