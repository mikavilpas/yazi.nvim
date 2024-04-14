local assert = require('luassert')
local event_handling = require('yazi.event_handling')

describe('process_delete_event', function()
  before_each(function()
    -- clear all buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it('deletes a buffer that matches the delete event exactly', function()
    local buffer = vim.fn.bufadd('/abc/def')

    ---@type YaziDeleteEvent
    local event = {
      type = 'delete',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { urls = { '/abc/def' } },
    }

    event_handling.process_delete_event(event, {})

    assert.is_false(vim.api.nvim_buf_is_valid(buffer))
  end)

  it('deletes a buffer that matches the parent directory', function()
    local buffer = vim.fn.bufadd('/abc/def')

    ---@type YaziDeleteEvent
    local event = {
      type = 'delete',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { urls = { '/abc' } },
    }

    event_handling.process_delete_event(event, {})

    assert.is_false(vim.api.nvim_buf_is_valid(buffer))
  end)

  it("doesn't delete a buffer that doesn't match the delete event", function()
    local buffer = vim.fn.bufadd('/abc/def')

    ---@type YaziDeleteEvent
    local event = {
      type = 'delete',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { urls = { '/abc/ghi' } },
    }

    event_handling.process_delete_event(event, {})

    assert.is_true(vim.api.nvim_buf_is_valid(buffer))
  end)

  it("doesn't delete a buffer that was renamed to in a later event", function()
    local buffer1 = vim.fn.bufadd('/def/file')

    ---@type YaziDeleteEvent
    local delete_event = {
      type = 'delete',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { urls = { '/def/file' } },
    }

    ---@type YaziRenameEvent
    local rename_event = {
      type = 'rename',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { from = '/def/other-file', to = '/def/file' },
    }

    event_handling.process_delete_event(delete_event, { rename_event })

    assert.is_true(vim.api.nvim_buf_is_valid(buffer1))
  end)
end)
