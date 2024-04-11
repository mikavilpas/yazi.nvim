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
      yazi_opened_multiple_files = function(chosen_files)
        -- show the items it the quickfix list
        vim.fn.setqflist({}, 'r', {
          title = 'Yazi',
          items = vim.tbl_map(function(file)
            return {
              filename = file,
              lnum = 1,
              text = file,
            }
          end, chosen_files),
        })

        -- open the quickfix window
        vim.cmd('copen')
      end,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
  }
end

return M
