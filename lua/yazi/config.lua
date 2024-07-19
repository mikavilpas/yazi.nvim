---@module "plenary.path"

local openers = require('yazi.openers')
local keybinding_helpers = require('yazi.keybinding_helpers')

local M = {}

function M.default()
  ---@type YaziConfig
  return {
    log_level = vim.log.levels.OFF,
    open_for_directories = false,
    -- NOTE: right now this is opt-in, but will be the default in the future
    use_ya_for_events_reading = false,
    use_yazi_client_id_flag = false,
    enable_mouse_support = false,
    open_file_function = openers.open_file,
    set_keymappings_function = M.default_set_keymappings_function,
    hooks = {
      yazi_opened = function() end,
      yazi_closed_successfully = function() end,
      yazi_opened_multiple_files = openers.send_files_to_quickfix_list,
    },

    highlight_groups = {
      hovered_buffer = nil,
    },

    integrations = {
      grep_in_directory = function(directory)
        require('telescope.builtin').live_grep({
          search = '',
          prompt_title = 'Grep in ' .. directory,
          cwd = directory,
        })
      end,
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
    keybinding_helpers.open_file_in_vertical_split(config)
  end, { buffer = yazi_buffer })
  vim.keymap.set('t', '<esc>', '<esc>', { buffer = yazi_buffer })

  -- LazyVim sets <esc><esc> to forcibly enter normal mode. This has been
  -- confusing for some users. Let's disable it when using yazi.nvim only.
  vim.keymap.set({ 't' }, '<esc><esc>', '<Nop>', { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-x>', function()
    keybinding_helpers.open_file_in_horizontal_split(config)
  end, { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-t>', function()
    keybinding_helpers.open_file_in_tab(config)
  end, { buffer = yazi_buffer })

  vim.keymap.set({ 't' }, '<c-s>', function()
    keybinding_helpers.select_current_file_and_close_yazi(config, {
      on_file_opened = function(_, _, state)
        if config.integrations.grep_in_directory == nil then
          return
        end

        local success, result_or_error = pcall(
          config.integrations.grep_in_directory,
          state.last_directory.filename
        )

        if not success then
          local message = 'yazi.nvim: error searching with telescope.'
          vim.notify(message, vim.log.levels.WARN)
          require('yazi.log'):debug(
            vim.inspect({ message = message, error = result_or_error })
          )
        end
      end,
    })
  end, { buffer = yazi_buffer })
end

return M
