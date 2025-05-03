-- This file is about handling events that are sent from yazi

local utils = require("yazi.utils")
local plenaryIterators = require("plenary.iterators")

local M = {}

---@param event YaziDeleteEvent | YaziTrashEvent
---@param config YaziConfig
---@param remaining_events YaziEvent[]
function M.process_delete_event(event, config, remaining_events)
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
            utils.bufdelete(
              config.integrations.bufdelete_implementation,
              buffer.bufnr
            )
            require("yazi.lsp.delete").file_deleted(buffer.path.filename)
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

---@param config YaziConfig
---@param event_data YaziEventDataRenameOrMove
local function handle_rename_move_bulk_event(config, event_data)
  local rename_instructions =
    M.get_buffers_that_need_renaming_after_yazi_exited(event_data)

  for _, instruction in ipairs(rename_instructions) do
    utils.rename_or_close_buffer(config, instruction)
  end
end

---@param events YaziEvent[]
---@param config YaziConfig
---@param context YaziActiveContext
function M.process_events_emitted_from_yazi(events, config, context)
  local lsp_rename = require("yazi.lsp.rename")
  for i, event in ipairs(events) do
    if event.type == "rename" then
      ---@cast event YaziRenameEvent
      lsp_rename.file_renamed(event.data.from, event.data.to)

      handle_rename_move_bulk_event(config, event.data)
    elseif event.type == "move" then
      ---@type YaziMoveEvent
      local move_event = event

      for _, item in ipairs(move_event.data.items) do
        lsp_rename.file_renamed(item.from, item.to)

        handle_rename_move_bulk_event(config, item)
      end
    elseif event.type == "bulk" then
      ---@cast event YaziBulkEvent
      for from, to in pairs(event.changes) do
        lsp_rename.file_renamed(from, to)

        handle_rename_move_bulk_event(config, { from = from, to = to })
      end
    elseif event.type == "delete" then
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziDeleteEvent
      M.process_delete_event(event, config, remaining_events)
    elseif event.type == "trash" then
      -- selene: allow(if_same_then_else)
      local remaining_events = vim.list_slice(events, i)
      ---@cast event YaziTrashEvent
      M.process_delete_event(event, config, remaining_events)
    elseif event.type == "cycle-buffer" then
      require("yazi.log"):debug("YaziNvimCycleBufferEvent received")
      ---@cast event YaziNvimCycleBufferEvent
      require("yazi.keybinding_helpers").cycle_open_buffers(config, context)
    end
  end
end

return M
