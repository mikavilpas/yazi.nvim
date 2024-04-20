local M = {}

---@param path string
local function notify_file_was_deleted(path)
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_willDeleteFiles
  local method = 'workspace/willDeleteFiles'

  local clients = vim.lsp.get_clients({
    method = method,
    bufnr = vim.api.nvim_get_current_buf(),
  })

  for _, client in ipairs(clients) do
    local resp = client.request_sync(method, {
      files = {
        {
          uri = vim.uri_from_fname(path),
        },
      },
    }, 1000, 0)

    if resp and resp.result ~= nil then
      vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
    end
  end
end

---@param path string
local function notify_delete_complete(path)
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didDeleteFiles
  local method = 'workspace/didDeleteFiles'

  local clients = vim.lsp.get_clients({
    method = method,
    bufnr = vim.api.nvim_get_current_buf(),
  })

  for _, client in ipairs(clients) do
    -- NOTE: this returns nothing, so no need to do anything with the response
    client.request_sync(method, {
      files = {
        {
          uri = vim.uri_from_fname(path),
        },
      },
    }, 1000, 0)
  end
end

-- Send a notification to LSP servers, letting them know that yazi just deleted some files
---@param path string
function M.file_deleted(path)
  notify_file_was_deleted(path)
  notify_delete_complete(path)
end

return M
