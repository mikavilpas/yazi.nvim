local utils =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.utils")
local log =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.log")

local M = {}

local function getWorkspaceEdit(client, fname)
  local will_create_params = {
    files = {
      {
        uri = vim.uri_from_fname(fname),
      },
    },
  }
  log.debug("Sending workspace/willCreateFiles request", will_create_params)
  local timeout_ms = require(
    "yazi.lsp.embedded-lsp-file-operations.lsp-file-operations"
  ).config.timeout_ms
  local success, resp = pcall(
    client.request_sync,
    "workspace/willCreateFiles",
    will_create_params,
    timeout_ms
  )
  log.debug("Got workspace/willCreateFiles response", resp)
  if not success then
    log.error("Error while sending workspace/willCreateFiles request", resp)
    return nil
  end
  if resp == nil or resp.result == nil then
    log.warn("Got empty workspace/willCreateFiles response, maybe a timeout?")
    return nil
  end
  return resp.result
end

M.callback = function(data)
  local clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  for _, client in pairs(clients()) do
    local will_create = utils.get_nested_path(
      client,
      { "server_capabilities", "workspace", "fileOperations", "willCreate" }
    )
    if will_create ~= nil then
      local filters = will_create.filters or {}
      if utils.matches_filters(filters, data.fname) then
        local edit = getWorkspaceEdit(client, data.fname)
        if edit ~= nil then
          log.debug("Going to apply workspace/willCreateFiles edit", edit)
          vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
        end
      end
    end
  end
end

return M
