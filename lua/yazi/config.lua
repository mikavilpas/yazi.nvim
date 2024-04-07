local M = {}

---@return YaziConfig
function M.default()
  ---@type YaziConfig
  return {
    open_for_directories = false,
    chosen_file_path = '/tmp/yazi_filechosen',
    events_file_path = '/tmp/yazi.nvim.events.txt',
    hooks = {
      ---@diagnostic disable-next-line: unused-local
      yazi_closed_successfully = function(_chosen_file) end,
    },
  }
end

return M
