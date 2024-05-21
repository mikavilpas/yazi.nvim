local openers = require('yazi.openers')

local M = {}

function M.default()
  ---@type YaziConfig
  return {
    log_level = vim.log.levels.OFF,
    open_for_directories = false,
    enable_mouse_support = false,
    open_file_function = openers.open_file,
    set_keymappings_function = M.default_set_keymappings_function,
    hooks = {
      yazi_opened = function() end,
      yazi_closed_successfully = function() end,
      yazi_opened_multiple_files = openers.send_files_to_quickfix_list,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
    yazi_floating_window_border = 'rounded',
  }
end

--- This sets the default keymappings for yazi. If you want to use your own
--- keymappings, you can set the set_keymappings_function in your config. Copy
--- this function as the basis.
---@param yazi_buffer integer
---@param config YaziConfig
function M.default_set_keymappings_function(yazi_buffer, config)
  vim.keymap.set({ 't' }, '<c-v>', function()
    M.open_file_in_vertical_split(config)
  end, { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-x>', function()
    M.open_file_in_horizontal_split(config)
  end, { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-t>', function()
    M.open_file_in_tab(config)
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

---@param config YaziConfig
function M.open_file_in_vertical_split(config)
  config.open_file_function = openers.open_file_in_vertical_split
  config.hooks.yazi_opened_multiple_files = function(chosen_files)
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config)
    end
  end
  M.select_current_file_and_close_yazi()
end

---@param config YaziConfig
function M.open_file_in_horizontal_split(config)
  config.open_file_function = openers.open_file_in_horizontal_split
  config.hooks.yazi_opened_multiple_files = function(chosen_files)
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config)
    end
  end
  M.select_current_file_and_close_yazi()
end

---@param config YaziConfig
function M.open_file_in_tab(config)
  config.open_file_function = openers.open_file_in_tab
  config.hooks.yazi_opened_multiple_files = function(chosen_files)
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config)
    end
  end
  M.select_current_file_and_close_yazi()
end

return M
