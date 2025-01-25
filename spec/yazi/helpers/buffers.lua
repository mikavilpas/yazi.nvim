local M = {}

function M.add_listed_buffer(path)
  local buffer = vim.fn.bufadd(path)
  vim.api.nvim_set_option_value("buflisted", true, { buf = buffer })
  return buffer
end

return M
