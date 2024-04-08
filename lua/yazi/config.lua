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
      yazi_opened = function(_preselected_path) end,
      ---@diagnostic disable-next-line: unused-local
      yazi_closed_successfully = function(_chosen_file) end,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
  }
end

return M
