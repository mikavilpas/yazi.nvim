local M = {}

function M.clear_all_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

function M.close_all_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    pcall(vim.api.nvim_win_close, win, true)
  end
end

return M
