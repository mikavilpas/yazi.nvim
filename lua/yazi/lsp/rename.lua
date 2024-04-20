local lsp_util = require('yazi.lsp.lsp_util')

local M = {}

---@param from string
---@param to string
local function notify_file_was_renamed(from, to)
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_willRenameFiles
  local method = 'workspace/willRenameFiles'

  local clients = lsp_util.get_clients(method, vim.api.nvim_get_current_buf())

  for _, client in ipairs(clients) do
    local resp = client.request_sync(method, {
      files = {
        {
          oldUri = vim.uri_from_fname(from),
          newUri = vim.uri_from_fname(to),
        },
      },
    }, 1000, 0)

    if resp and resp.result ~= nil then
      vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
    end
  end
end

---@param from string
---@param to string
local function notify_rename_complete(from, to)
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didRenameFiles
  local method = 'workspace/didRenameFiles'

  local clients = lsp_util.get_clients(method, vim.api.nvim_get_current_buf())

  for _, client in ipairs(clients) do
    -- NOTE: this returns nothing, so no need to do anything with the response
    client.request_sync(method, {
      files = {
        oldUri = vim.uri_from_fname(from),
        newUri = vim.uri_from_fname(to),
      },
    }, 1000, 0)
  end
end

-- Send a notification to LSP servers, letting them know that yazi just renamed some files
---@param from string
---@param to string
function M.file_renamed(from, to)
  notify_file_was_renamed(from, to)
  notify_rename_complete(from, to)
end

return M
