local openers = require('yazi.openers')

local M = {}

function M.default()
  ---@type YaziConfig
  return {
    open_for_directories = false,
    chosen_file_path = '/tmp/yazi_filechosen',
    events_file_path = '/tmp/yazi.nvim.events.txt',
    open_file_function = openers.open_file,
    set_keymappings_function = M.default_set_keymappings_function,
    hooks = {
      yazi_opened = function() end,
      yazi_closed_successfully = function() end,
      yazi_opened_multiple_files = openers.send_files_to_quickfix_list,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
  }
end

---@param yazi_buffer integer
---@param config YaziConfig
function M.default_set_keymappings_function(yazi_buffer, config)
  vim.keymap.set({ 't' }, '<c-v>', function()
    config.open_file_function = openers.open_file_in_vertical_split
    M.select_current_file_and_close_yazi()
  end, { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-s>', function()
    config.open_file_function = openers.open_file_in_horizontal_split
    M.select_current_file_and_close_yazi()
  end, { buffer = yazi_buffer })
end

-- This is a utility function that can be used in the set_keymappings_function
-- You can also use it in your own keymappings function
function M.select_current_file_and_close_yazi()
  -- select the current file in yazi and close it (enter is the default
  -- keybinding for selecting a file)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<enter>', true, false, true),
    'n',
    true
  )
end

return M
