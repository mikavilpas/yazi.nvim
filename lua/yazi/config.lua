---@module "plenary.path"

local openers = require("yazi.openers")

local M = {}

function M.default()
  ---@type YaziConfig
  return {
    -- Below is the default configuration. It is optional to set these values.
    -- You can customize the configuration for each yazi call by passing it to
    -- yazi() explicitly

    -- enable this if you want to open yazi instead of netrw.
    -- Note that if you enable this, you need to call yazi.setup() to
    -- initialize the plugin. lazy.nvim does this for you in certain cases.
    --
    -- If you are also using neotree, you may prefer not to bring it up when
    -- opening a directory:
    -- {
    --   "nvim-neo-tree/neo-tree.nvim",
    --   opts = {
    --     filesystem = {
    --       hijack_netrw_behavior = "disabled",
    --     },
    --   },
    -- }
    open_for_directories = false,

    -- the log level to use. Off by default, but can be used to diagnose
    -- issues. You can find the location of the log file by running
    -- `:checkhealth yazi` in Neovim. Also check out the "reproducing issues"
    -- section below
    log_level = vim.log.levels.OFF,

    -- open visible splits as yazi tabs for easy navigation. Requires a yazi
    -- version more recent than 2024-08-11
    -- https://github.com/mikavilpas/yazi.nvim/pull/359
    open_multiple_tabs = false,
    enable_mouse_support = false,

    -- what Neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    open_file_function = openers.open_file,

    -- some yazi.nvim commands copy text to the clipboard. This is the register
    -- yazi.nvim should use for copying. Defaults to "*", the system clipboard
    clipboard_register = "*",

    -- customize the keymaps that are active when yazi is open and focused. The
    -- defaults are listed below. Also:
    -- - use e.g. `open_file_in_tab = false` to disable a keymap
    -- - you can customize only some of the keymaps if you want
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
    },

    -- completely override the keymappings for yazi. This function will be
    -- called in the context of the yazi terminal buffer.
    set_keymappings_function = nil,

    -- run your own custom code when yazi.nvim does some actions. See types.lua
    -- for the exact signatures of these functions.
    hooks = {
      -- if you want to execute a custom action when yazi has been opened,
      -- you can define it here.
      yazi_opened = function()
        -- you can optionally modify the config for this specific yazi
        -- invocation if you want to customize the behaviour
      end,

      -- when yazi was successfully closed
      yazi_closed_successfully = function() end,

      -- when yazi opened multiple files. The default is to send them to the
      -- quickfix list, but if you want to change that, you can define it here
      yazi_opened_multiple_files = openers.open_multiple_files,
    },

    -- highlight buffers in the same directory as the hovered buffer
    highlight_hovered_buffers_in_same_directory = true,
    highlight_groups = {
      -- See https://github.com/mikavilpas/yazi.nvim/pull/180
      hovered_buffer = nil,
      -- See https://github.com/mikavilpas/yazi.nvim/pull/351
      hovered_buffer_in_same_directory = nil,
    },
    integrations = {
      --- What should be done when the user wants to grep in a directory
      grep_in_directory = function(directory)
        -- the default implementation uses telescope if available, otherwise nothing
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
        require("grug-far").grug_far({
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

        require("grug-far").grug_far({
          prefills = {
            paths = table.concat(files, " "),
          },
        })
      end,
      resolve_relative_path_application = vim.uv.os_uname().sysname == "Darwin"
          and "grealpath"
        or "realpath",
    },

    -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
    floating_window_scaling_factor = 0.9,

    -- the transparency of the yazi floating window (0-100). See :h winblend
    yazi_floating_window_winblend = 0,

    -- the type of border to use for the floating window. Can be many values,
    -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
    -- more information, see :h nvim_open_win
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
      keybinding_helpers.cycle_open_buffers(context)
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
        height = math.min(13, math.floor(h * 0.5)),
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
        "" .. show(config.keymaps.show_help) .. " - show this help",
        "",
        "version *" .. require("yazi").version .. "*",
      })

      vim.api.nvim_set_option_value("filetype", "help", { buf = help_buffer })
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
