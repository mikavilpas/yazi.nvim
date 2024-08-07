-- This file is about emitting events to other Neovim plugins

local M = {}

---@alias YaziNeovimEvent
---| "'YaziDDSHover'" A file was hovered over in yazi

---@param event_name YaziNeovimEvent
---@param event_data table
function M.emit(event_name, event_data)
  vim.api.nvim_exec_autocmds('User', {
    pattern = event_name,
    data = event_data,
  })
end

return M
