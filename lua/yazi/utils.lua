local fn = vim.fn

local M = {}

---@return boolean
function M.is_yazi_available()
  return fn.executable('yazi') == 1
end

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

return M
