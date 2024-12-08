---@module "plenary.path"

local M = {}

function M.default()
  local openers = require("yazi.openers")

  local relpath = nil
  if vim.uv.os_uname().sysname == "Darwin" then
    relpath = "grealpath"
  else
    relpath = "realpath"
  end

  ---@type YaziConfig
  return {
    log_level = vim.log.levels.OFF,
    open_for_directories = false,
    future_features = {},
    open_multiple_tabs = false,
    enable_mouse_support = false,
    open_file_function = openers.open_file,
    clipboard_register = "*",
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
      change_working_directory = "<c-\\>",
    },
    set_keymappings_function = nil,
    hooks = {
      yazi_opened = function() end,
      yazi_closed_successfully = function() end,
      yazi_opened_multiple_files = openers.open_multiple_files,
    },
    highlight_hovered_buffers_in_same_directory = true,
    highlight_groups = {
      hovered_buffer = nil,
      hovered_buffer_in_same_directory = nil,
    },
    integrations = {
      grep_in_directory = function(directory)
        require("telescope.builtin").live_grep({
          search = "",
          prompt_title = "Grep in " .. directory,
          cwd = directory,
        })
      end,
      grep_in_selected_files = function(selected_files)
        ---@type string[]
        local files = {}
        for _, path in ipairs(selected_files) do
          files[#files + 1] = path:make_relative(vim.uv.cwd()):gsub(" ", "\\ ")
        end

        require("telescope.builtin").live_grep({
          search = "",
          prompt_title = string.format("Grep in %d paths", #files),
          search_dirs = files,
        })
      end,
      replace_in_directory = function(directory)
        -- limit the search to the given path
        --
        -- `prefills.flags` get passed to ripgrep as is
        -- https://github.com/MagicDuck/grug-far.nvim/issues/146
        local filter = directory:make_relative(vim.uv.cwd())
        require("grug-far").open({
          prefills = {
            paths = filter:gsub(" ", "\\ "),
          },
        })
      end,
      replace_in_selected_files = function(selected_files)
        ---@type string[]
        local files = {}
        for _, path in ipairs(selected_files) do
          files[#files + 1] = path:make_relative(vim.uv.cwd()):gsub(" ", "\\ ")
        end

        require("grug-far").open({
          prefills = {
            paths = table.concat(files, " "),
          },
        })
      end,
      resolve_relative_path_application = relpath,
    },

    floating_window_scaling_factor = 0.9,
    yazi_floating_window_winblend = 0,
    yazi_floating_window_border = "rounded",
  }
end

---@param yazi_buffer integer
---@param config YaziConfig
---@param context YaziActiveContext
function M.set_keymappings(yazi_buffer, config, context)
  local keybinding_helpers = require("yazi.keybinding_helpers")

  if config.keymaps == false then
    return
  end

  if config.keymaps.open_file_in_vertical_split ~= false then
    vim.keymap.set(
      { "t" },
      config.keymaps.open_file_in_vertical_split,
      function()
        keybinding_helpers.open_file_in_vertical_split(config)
      end,
      { buffer = yazi_buffer }
    )
  end

  if config.keymaps.open_file_in_horizontal_split ~= false then
    vim.keymap.set(
      { "t" },
      config.keymaps.open_file_in_horizontal_split,
      function()
        keybinding_helpers.open_file_in_horizontal_split(config)
      end,
      { buffer = yazi_buffer }
    )
  end

  if config.keymaps.grep_in_directory ~= false then
    vim.keymap.set({ "t" }, config.keymaps.grep_in_directory, function()
      keybinding_helpers.select_current_file_and_close_yazi(config, {
        on_file_opened = function(chosen_file, _, _)
          keybinding_helpers.grep_in_directory(config, chosen_file)
        end,
        on_multiple_files_opened = function(chosen_files)
          keybinding_helpers.grep_in_selected_files(config, chosen_files)
        end,
      })
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.open_file_in_tab ~= false then
    vim.keymap.set({ "t" }, config.keymaps.open_file_in_tab, function()
      keybinding_helpers.open_file_in_tab(config)
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.cycle_open_buffers ~= false then
    vim.keymap.set({ "t" }, config.keymaps.cycle_open_buffers, function()
      keybinding_helpers.cycle_open_buffers(config, context)
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.replace_in_directory ~= false then
    vim.keymap.set({ "t" }, config.keymaps.replace_in_directory, function()
      keybinding_helpers.select_current_file_and_close_yazi(config, {
        on_file_opened = function(chosen_file)
          keybinding_helpers.replace_in_directory(config, chosen_file)
        end,
        on_multiple_files_opened = function(chosen_files)
          keybinding_helpers.replace_in_selected_files(config, chosen_files)
        end,
      })
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.send_to_quickfix_list ~= false then
    vim.keymap.set({ "t" }, config.keymaps.send_to_quickfix_list, function()
      local openers = require("yazi.openers")
      keybinding_helpers.select_current_file_and_close_yazi(config, {
        on_multiple_files_opened = openers.send_files_to_quickfix_list,
        on_file_opened = function(chosen_file)
          openers.send_files_to_quickfix_list({ chosen_file })
        end,
      })
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.change_working_directory ~= false then
    vim.keymap.set({ "t" }, config.keymaps.change_working_directory, function()
      keybinding_helpers.change_working_directory(context)
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.show_help ~= false then
    vim.keymap.set({ "t" }, config.keymaps.show_help, function()
      local w = vim.api.nvim_win_get_width(0)
      local h = vim.api.nvim_win_get_height(0)

      local help_buffer = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(help_buffer, true, {
        style = "minimal",
        relative = "win",
        bufpos = { 5, 30 },
        noautocmd = true,
        width = math.min(46, math.floor(w * 0.5)),
        height = math.min(14, math.floor(h * 0.5)),
        border = config.yazi_floating_window_border,
      })

      local function show(key)
        return key or "<Nop>"
      end

      -- write the help text. Hopefully the vim help syntax is always bundled
      -- and available so that nice highlights can be shown.
      vim.api.nvim_buf_set_lines(help_buffer, 0, -1, false, {
        "yazi.nvim help (`q` or " .. config.keymaps.show_help .. " to close):",
        "",
        "" .. show(config.keymaps.open_file_in_tab) .. " - open file in tab",
        ""
          .. show(config.keymaps.open_file_in_horizontal_split)
          .. " - open file in horizontal split",
        ""
          .. show(config.keymaps.open_file_in_vertical_split)
          .. " - open file in vertical split",
        ""
          .. show(config.keymaps.send_to_quickfix_list)
          .. " - send to the quickfix list",
        ""
          .. show(config.keymaps.grep_in_directory)
          .. " - search in directory / selected files",
        ""
          .. show(config.keymaps.replace_in_directory)
          .. " - replace in directory / selected files",
        ""
          .. show(config.keymaps.cycle_open_buffers)
          .. " - cycle open buffers",
        ""
          .. show(config.keymaps.copy_relative_path_to_selected_files)
          .. " - copy relative path to selected file(s)",
        ""
          .. show(config.keymaps.change_working_directory)
          .. " - change cwd to current directory",
        "" .. show(config.keymaps.show_help) .. " - show this help",
        "",
        "version *" .. require("yazi").version .. "*",
      })

      vim.api.nvim_set_option_value("syntax", "help", { buf = help_buffer })
      vim.api.nvim_set_option_value("concealcursor", "nc", { win = win })
      vim.api.nvim_set_option_value("conceallevel", 2, { win = win })
      vim.api.nvim_set_option_value("modifiable", false, { buf = help_buffer })

      local function close_help()
        vim.api.nvim_win_close(win, true)
        vim.cmd("startinsert")
      end

      -- exit with q and the help menu key
      vim.keymap.set({ "n" }, "q", function()
        close_help()
      end, { buffer = help_buffer })
      vim.keymap.set({ "n" }, config.keymaps.show_help, function()
        close_help()
      end, { buffer = help_buffer })
    end, { buffer = yazi_buffer })
  end

  if config.keymaps.copy_relative_path_to_selected_files ~= false then
    vim.keymap.set(
      { "t" },
      config.keymaps.copy_relative_path_to_selected_files,
      function()
        keybinding_helpers.select_current_file_and_close_yazi(config, {
          on_file_opened = function(chosen_file)
            local relative_path = require("yazi.utils").relative_path(
              config,
              context.input_path.filename,
              chosen_file
            )

            vim.fn.setreg(config.clipboard_register, relative_path, "c")
          end,
          on_multiple_files_opened = function(chosen_files)
            local relative_paths = {}
            for _, path in ipairs(chosen_files) do
              relative_paths[#relative_paths + 1] =
                require("yazi.utils").relative_path(
                  config,
                  context.input_path.filename,
                  path
                )
            end

            vim.fn.setreg(
              config.clipboard_register,
              table.concat(relative_paths, "\n"),
              "c"
            )
          end,
        })
      end,
      { buffer = yazi_buffer }
    )
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
