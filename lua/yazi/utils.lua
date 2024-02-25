local fn = vim.fn

local M = {}

---@return boolean
function M.is_yazi_available()
  return fn.executable('yazi') == 1
end

return M
