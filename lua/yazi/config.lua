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
    keymaps = {
      open_file_in_vertical_split = '<c-v>',
      open_file_in_horizontal_split = '<c-x>',
      open_file_in_tab = '<c-t>',
      grep_in_directory = '<c-s>',
      replace_in_directory = '<c-g>',
      cycle_open_buffers = '<tab>',
    },
    set_keymappings_function = nil,
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
      replace_in_directory = function(directory)
        -- limit the search to the given path
        --
        -- `prefills.flags` get passed to ripgrep as is
        -- https://github.com/MagicDuck/grug-far.nvim/issues/146
        local filter = directory:make_relative(vim.uv.cwd())
        require('grug-far').grug_far({
          prefills = {
            flags = filter,
          },
        })
      end,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
    yazi_floating_window_border = 'rounded',
  }
end

---@param yazi_buffer integer
---@param config YaziConfig
---@param context YaziActiveContext
function M.set_keymappings(yazi_buffer, config, context)
  if config.keymaps == false then
    return
  end

  if config.keymaps.open_file_in_vertical_split ~= false then
    vim.keymap.set(
      { 't' },
      config.keymaps.open_file_in_vertical_split,
      function()
        keybinding_helpers.open_file_in_vertical_split(config)
      end,
      { buffer = yazi_buffer }
    )
  end

  if config.keymaps.open_file_in_horizontal_split ~= false then
    vim.keymap.set(
      { 't' },
      config.keymaps.open_file_in_horizontal_split,
      function()
        keybinding_helpers.open_file_in_horizontal_split(config)
      end,
      { buffer = yazi_buffer }
    )
  end

  if config.keymaps.grep_in_directory ~= false then
    vim.keymap.set({ 't' }, config.keymaps.grep_in_directory, function()
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

  if config.keymaps.open_file_in_tab ~= false then
    vim.keymap.set({ 't' }, config.keymaps.open_file_in_tab, function()
      keybinding_helpers.open_file_in_tab(config)
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.cycle_open_buffers ~= false then
    vim.keymap.set({ 't' }, config.keymaps.cycle_open_buffers, function()
      keybinding_helpers.cycle_open_buffers(context)
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.replace_in_directory ~= false then
    vim.keymap.set({ 't' }, config.keymaps.replace_in_directory, function()
      keybinding_helpers.select_current_file_and_close_yazi(config, {
        on_file_opened = function(_, _, state)
          if config.integrations.replace_in_directory == nil then
            return
          end

          local success, result_or_error = pcall(
            config.integrations.replace_in_directory,
            state.last_directory
          )

          if not success then
            local message = 'yazi.nvim: error replacing with grug-far.nvim.'
            vim.notify(message, vim.log.levels.WARN)
            require('yazi.log'):debug(
              vim.inspect({ message = message, error = result_or_error })
            )
          end
        end,
      })
    end, { buffer = yazi_buffer })
  end
end

---@param yazi_buffer integer
---@param config YaziConfig
---@param context YaziActiveContext
---@deprecated Prefer using `keymaps` in the config instead of this function. It's a clearer way of doing the exact same thing.
function M.default_set_keymappings_function(yazi_buffer, config, context)
  return M.set_keymappings(yazi_buffer, config, context)
end

return M
