-- This file is about handling events that are sent from yazi

local utils = require("yazi.utils")
local plenaryIterators = require("plenary.iterators")
local lsp_delete = require("yazi.lsp.delete")
local lsp_rename = require("yazi.lsp.rename")

local M = {}

---@param event YaziDeleteEvent | YaziTrashEvent
---@param remaining_events YaziEvent[]
function M.process_delete_event(event, remaining_events)
  local open_buffers = utils.get_open_buffers()

  ---@type RenameableBuffer[]
  local deleted_buffers = {}

  for _, buffer in ipairs(open_buffers) do
    for _, url in ipairs(event.data.urls) do
      if buffer:matches_exactly(url) or buffer:matches_parent(url) then
        local is_renamed_in_later_event = plenaryIterators
          .iter(remaining_events)
          :find(
            ---@param e YaziEvent
            function(e)
              return e.type == "rename" and e.data.to == url
            end
          )

        if is_renamed_in_later_event then
          break
        else
          deleted_buffers[#deleted_buffers + 1] = buffer

          vim.schedule(function()
            vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
            lsp_delete.file_deleted(buffer.path.filename)
          end)
        end
      end
    end
  end

  return deleted_buffers
end

---@param rename_or_move_event YaziEventDataRenameOrMove
---@return RenameableBuffer[] "instructions for renaming the buffers (command pattern)"
function M.get_buffers_that_need_renaming_after_yazi_exited(
  rename_or_move_event
)
  local open_buffers = utils.get_open_buffers()

  ---@type table<integer, RenameableBuffer>
  local renamed_buffers = {}

  local event = rename_or_move_event
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

---@param events YaziEvent[]
function M.process_events_emitted_from_yazi(events)
  for i, event in ipairs(events) do
    if event.type == "rename" then
      ---@cast event YaziRenameEvent
      lsp_rename.file_renamed(event.data.from, event.data.to)

      local rename_instructions =
        M.get_buffers_that_need_renaming_after_yazi_exited(event.data)
      for _, instruction in ipairs(rename_instructions) do
        utils.rename_or_close_buffer(instruction)
      end
    elseif event.type == "move" then
      ---@cast event YaziMoveEvent
      for _, item in ipairs(event.data.items) do
        lsp_rename.file_renamed(item.from, item.to)

        local rename_instructions =
          M.get_buffers_that_need_renaming_after_yazi_exited(item)
        for _, instruction in ipairs(rename_instructions) do
          utils.rename_or_close_buffer(instruction)
        end
      end
    elseif event.type == "bulk" then
      ---@cast event YaziBulkEvent
      for from, to in pairs(event.changes) do
        lsp_rename.file_renamed(from, to)

        local rename_instructions =
          M.get_buffers_that_need_renaming_after_yazi_exited({
            from = from,
            to = to,
          })
        for _, instruction in ipairs(rename_instructions) do
          utils.rename_or_close_buffer(instruction)
        end
      end
    elseif event.type == "delete" then
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziDeleteEvent
      M.process_delete_event(event, remaining_events)
    elseif event.type == "trash" then
      -- selene: allow(if_same_then_else)
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziTrashEvent
      M.process_delete_event(event, remaining_events)
    end
  end
end

return M
