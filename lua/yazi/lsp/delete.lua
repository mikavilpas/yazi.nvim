local will_delete = require(
  "yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.will-delete"
)
local did_delete = require(
  "yazi.lsp.embedded-lsp-file-operations.lsp-file-operations.did-delete"
)

local M = {}

-- Send a notification to LSP servers, letting them know that yazi just deleted
-- some files. Execute any changes that the LSP says are needed in other files.
---@param path string
function M.file_deleted(path)
  will_delete.callback({ fname = path })
  did_delete.callback({ fname = path })
end

return M
