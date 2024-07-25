local utils = require('yazi.lsp.embedded.lsp-file-operations.utils')
local log = require('yazi.lsp.embedded.lsp-file-operations.log')

local M = {}

M.callback = function(data)
  for _, client in pairs(vim.lsp.get_active_clients()) do
    local did_delete = utils.get_nested_path(
      client,
      { 'server_capabilities', 'workspace', 'fileOperations', 'didDelete' }
    )
    if did_delete ~= nil then
      local filters = did_delete.filters or {}
      if utils.matches_filters(filters, data.fname) then
        local params = {
          files = {
            { uri = vim.uri_from_fname(data.fname) },
          },
        }
        client.notify('workspace/didDeleteFiles', params)
        log.debug('Sending workspace/didDeleteFiles notification', params)
      end
    end
  end
end

return M
