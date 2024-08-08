local utils =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.utils")
local log =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.log")

local M = {}

local function getWorkspaceEdit(client, fname)
  local will_delete_params = {
    files = {
      {
        uri = vim.uri_from_fname(fname),
      },
    },
  }
  log.debug("Sending workspace/willDeleteFiles request", will_delete_params)
  local timeout_ms = require(
    "yazi.lsp.embedded-lsp-file-operations.lsp-file-operations"
  ).config.timeout_ms
  local success, resp = pcall(
    client.request_sync,
    "workspace/willDeleteFiles",
    will_delete_params,
    timeout_ms
  )
  log.debug("Got workspace/willDeleteFiles response", resp)
  if not success then
    log.error("Error while sending workspace/willDeleteFiles request", resp)
    return nil
  end
  if resp == nil or resp.result == nil then
    log.warn("Got empty workspace/willDeleteFiles response, maybe a timeout?")
    return nil
  end
  return resp.result
end

M.callback = function(data)
  local clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  for _, client in pairs(clients()) do
    local will_delete = utils.get_nested_path(
      client,
      { "server_capabilities", "workspace", "fileOperations", "willDelete" }
    )
    if will_delete ~= nil then
      local filters = will_delete.filters or {}
      if utils.matches_filters(filters, data.fname) then
        local edit = getWorkspaceEdit(client, data.fname)
        if edit ~= nil then
          log.debug("Going to apply workspace/willDelete edit", edit)
          vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
        end
      end
    end
  end
end

return M
