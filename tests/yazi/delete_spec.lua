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

    vim.wait(1000, function()
      return not vim.api.nvim_buf_is_valid(buffer)
    end)
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

    vim.wait(1000, function()
      return not vim.api.nvim_buf_is_valid(buffer)
    end)
    assert.is_false(vim.api.nvim_buf_is_valid(buffer))
  end)

  it("doesn't delete a buffer that doesn't match the delete event", function()
    vim.fn.bufadd('/abc/def')

    ---@type YaziDeleteEvent
    local event = {
      type = 'delete',
      timestamp = '1712766606832135',
      id = '1712766606832135',
      data = { urls = { '/abc/ghi' } },
    }

    local deletions = event_handling.process_delete_event(event, {})

    -- NOTE waiting for something not to happen is not possible to do reliably.
    -- Inspect the return value so we can at least get some level of
    -- confidence.
    assert.are.same({}, deletions)
  end)

  it("doesn't delete a buffer that was renamed to in a later event", function()
    vim.fn.bufadd('/def/file')

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

    local deletions =
      event_handling.process_delete_event(delete_event, { rename_event })

    assert.are.same({}, deletions)
  end)
end)
