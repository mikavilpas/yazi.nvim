local M = {}

---@return YaziConfig
function M.default()
  return {
    open_for_directories = false,
    chosen_file_path = '/tmp/yazi_filechosen',
    events_file_path = '/tmp/yazi.nvim.events.txt',
  }
end

return M
