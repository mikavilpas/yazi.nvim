---@class YaziConfig
---@field public open_for_directories boolean

local M = {}

---@return YaziConfig
function M.default()
  return {
    open_for_directories = false,
  }
end

return M
