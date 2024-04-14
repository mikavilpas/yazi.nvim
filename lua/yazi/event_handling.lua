local utils = require('yazi.utils')
local plenaryIterators = require('plenary.iterators')

local M = {}

---@param event YaziDeleteEvent | YaziTrashEvent
---@param remaining_events YaziEvent[]
function M.process_delete_event(event, remaining_events)
  local open_buffers = utils.get_open_buffers()

  for _, buffer in ipairs(open_buffers) do
    for _, url in ipairs(event.data.urls) do
      if buffer:matches_exactly(url) or buffer:matches_parent(url) then
        local is_renamed_in_later_event = plenaryIterators
          .iter(remaining_events)
          :find(
            ---@param e YaziEvent
            function(e)
              return e.type == 'rename' and e.data.to == url
            end
          )

        if is_renamed_in_later_event then
          break
        else
          vim.api.nvim_buf_delete(buffer.bufnr, { force = false })
        end
      end
    end
  end
end

---@param rename_event YaziEventDataRenameOrMove
---@return RenameableBuffer[] "instructions for renaming the buffers (command pattern)"
function M.get_buffers_that_need_renaming_after_yazi_exited(rename_event)
  local open_buffers = utils.get_open_buffers()

  ---@type table<integer, RenameableBuffer>
  local renamed_buffers = {}

  local event = rename_event
  for _, buffer in ipairs(open_buffers) do
    if buffer:matches_exactly(event.from) then
      buffer:rename(event.to)
      renamed_buffers[buffer.bufnr] = buffer
    elseif buffer:matches_parent(event.from) then
      buffer:rename_parent(event.from, event.to)
      renamed_buffers[buffer.bufnr] = buffer
    end
  end

  return vim.tbl_values(renamed_buffers)
end

---@param config YaziConfig
function M.process_events_emitted_from_yazi(config)
  -- process events emitted from yazi
  local events = utils.read_events_file(config.events_file_path)

  for i, event in ipairs(events) do
    if event.type == 'rename' then
      ---@cast event YaziRenameEvent
      local rename_instructions =
        M.get_buffers_that_need_renaming_after_yazi_exited(event.data)
      for _, instruction in ipairs(rename_instructions) do
        vim.api.nvim_buf_set_name(instruction.bufnr, instruction.path.filename)
      end
    elseif event.type == 'move' then
      ---@cast event YaziMoveEvent
      for _, item in ipairs(event.data.items) do
        local rename_instructions =
          M.get_buffers_that_need_renaming_after_yazi_exited(item)
        for _, instruction in ipairs(rename_instructions) do
          vim.api.nvim_buf_set_name(
            instruction.bufnr,
            instruction.path.filename
          )
        end
      end
    elseif event.type == 'delete' then
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziDeleteEvent
      M.process_delete_event(event, remaining_events)
    elseif event.type == 'trash' then
      -- selene: allow(if_same_then_else)
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziTrashEvent
      M.process_delete_event(event, remaining_events)
    end
  end
end

return M
