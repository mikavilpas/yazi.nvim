-- This file is about emitting events to other Neovim plugins so that they can
-- react to things that happen in this plugin.

local M = {}

---@alias YaziNeovimEvent
---| "'YaziDDSHover'" A file was hovered over in yazi
---| "'YaziRenamedOrMoved'" Files were renamed or moved
---| "'YaziDDSCustom'" A custom event was received from yazi. The event was specifically subscribed to with the `forwarded_dds_events` yazi.nvim config option.

---@alias YaziNeovimEvent.YaziRenamedOrMovedData {changes: table<string, string>} # a table of old paths to new paths

---Emit an event when files are renamed or moved.
---@param event YaziRenameEvent | YaziMoveEvent | YaziBulkEvent
---@see YaziNeovimEvent.YaziRenamedOrMovedData
function M.emit_renamed_or_moved_event(event)
  ---@type YaziNeovimEvent.YaziRenamedOrMovedData
  local event_data = {
    changes = {},
  }

  if event.type == "move" or event.type == "rename" then
    event_data.changes[event.data.from] = event.data.to
  elseif event.type == "bulk" then
    event_data.changes = event.changes
  end

  M.emit("YaziRenamedOrMoved", event_data)
end

---@param event_name YaziNeovimEvent
---@param event_data table<string, unknown>
function M.emit(event_name, event_data)
  local Log = require("yazi.log")
  Log:debug(vim.inspect({ "emitting", event_name, event_data }))
  vim.api.nvim_exec_autocmds("User", {
    pattern = event_name,
    data = event_data,
  })
end

return M
