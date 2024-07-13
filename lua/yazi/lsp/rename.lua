local will_rename = require('lsp-file-operations.will-rename')
local did_rename = require('lsp-file-operations.did-rename')

local M = {}

-- Send a notification to LSP servers, letting them know that yazi just renamed
-- some files. Execute any changes that the LSP says are needed in other files.
---@param from string
---@param to string
function M.file_renamed(from, to)
  will_rename.callback({ old_name = from, new_name = to })
  did_rename.callback({ old_name = from, new_name = to })
end

return M
