local M = {}

---@return YaziConfig
function M.default()
  ---@type YaziConfig
  return {
    open_for_directories = false,
    chosen_file_path = '/tmp/yazi_filechosen',
    events_file_path = '/tmp/yazi.nvim.events.txt',
    open_file_function = function(chosen_file)
      vim.cmd(string.format('edit %s', chosen_file))
    end,
    hooks = {
      ---@diagnostic disable-next-line: unused-local
      yazi_closed_successfully = function(_chosen_file) end,
    },
  }
end

return M
