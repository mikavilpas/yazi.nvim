local M = {}

-- For nvim 0.9 compatibility
---@param lsp_method string
---@param bufnr number
function M.get_clients(lsp_method, bufnr)
  -- TODO remove this when we drop support for nvim 0.9

  ---@diagnostic disable-next-line: deprecated - but needed for compatibility
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  return vim.tbl_filter(function(client)
    return client.supports_method(lsp_method, { bufnr = bufnr })
  end, clients)
end

return M
