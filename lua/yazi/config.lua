local M = {}

---@return YaziConfig
function M.default()
  return {
    open_for_directories = false,
    chosen_file_path = '/tmp/yazi_filechosen',
  }
end

return M
