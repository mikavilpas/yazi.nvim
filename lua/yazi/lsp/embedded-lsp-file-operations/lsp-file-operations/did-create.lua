local utils =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.utils")
local log =
  require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.log")

local M = {}

M.callback = function(data)
  local clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  for _, client in pairs(clients()) do
    local did_create = utils.get_nested_path(
      client,
      { "server_capabilities", "workspace", "fileOperations", "didCreate" }
    )
    if did_create ~= nil then
      local filters = did_create.filters or {}
      if utils.matches_filters(filters, data.fname) then
        local params = {
          files = {
            { uri = vim.uri_from_fname(data.fname) },
          },
        }
        client.notify("workspace/didCreateFiles", params)
        log.debug("Sending workspace/didCreateFiles notification", params)
      end
    end
  end
end

return M
