local utils = require("lsp-file-operations.utils")
local log = require("lsp-file-operations.log")

local M = {}

local function getWorkspaceEdit(client, old_name, new_name)
  local will_rename_params = {
    files = {
      {
        oldUri = vim.uri_from_fname(old_name),
        newUri = vim.uri_from_fname(new_name),
      },
    },
  }
  log.debug("Sending workspace/willRenameFiles request", will_rename_params)
  local timeout_ms = require("lsp-file-operations").config.timeout_ms
  local success, resp = pcall(client.request_sync, "workspace/willRenameFiles", will_rename_params, timeout_ms)
  log.debug("Got workspace/willRenameFiles response", resp)
  if not success then
    log.error("Error while sending workspace/willRenameFiles request", resp)
    return nil
  end
  if resp == nil or resp.result == nil then
    log.warn("Got empty workspace/willRenameFiles response, maybe a timeout?")
    return nil
  end
  return resp.result
end

M.callback = function(data)
  for _, client in pairs(vim.lsp.get_active_clients()) do
    local will_rename =
      utils.get_nested_path(client, { "server_capabilities", "workspace", "fileOperations", "willRename" })
    if will_rename ~= nil then
      local filters = will_rename.filters or {}
      if utils.matches_filters(filters, data.old_name) then
        local edit = getWorkspaceEdit(client, data.old_name, data.new_name)
        if edit ~= nil then
          log.debug("Going to apply workspace/willRename edit", edit)
          vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
        end
      end
    end
  end
end

return M
