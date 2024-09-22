# 🎲 A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

> [!TIP]
>
> 2024-07: Some users are experiencing issues updating with lazy.nvim, and have
> reported uninstalling and reinstalling the plugin seems to work. More
> information can be found in
> [#198](https://github.com/mikavilpas/yazi.nvim/pull/198).

<a href="https://dotfyle.com/plugins/mikavilpas/yazi.nvim">
  <img src="https://dotfyle.com/plugins/mikavilpas/yazi.nvim/shield?style=flat-square" alt="shield image for plugin usage" /> </a>

[![LuaRocks](https://img.shields.io/luarocks/v/mikavilpas/yazi.nvim?logo=lua)](https://luarocks.org/modules/mikavilpas/yazi.nvim)
[![Type checked codebase](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml/badge.svg)](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml)

Yazi is a blazing fast file manager for the terminal. This plugin allows you to
open yazi in a floating window in Neovim.

<https://github.com/mikavilpas/yazi.nvim/assets/300791/c7ff98ee-54d6-4ad0-9318-903e4b674f84>

## ✨ Features

- Press `<f1>` to display all keymaps!
- Open yazi in a floating window. All visible splits are opened as yazi tabs for
  easy and fast navigation.
- Files that are hovered in yazi are highlighted in Neovim to intuitively show
  where you are in relation to your Neovim session. Currently this works for
  splits that you have open.
- Files selected in yazi can be opened in various ways: as the current buffer, a
  vertical split, a horizontal split, a new tab, as quickfix items...
- Integrations to other plugins and tools, if they are installed:

  - For [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim): you
    can grep/search in the directory yazi is in
  - For [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim): you can
    search and replace in the directory yazi is in
  - Copy the relative path from the start file to the currently hovered file.
    Requires
    [realpath (1)](https://www.man7.org/linux/man-pages/man1/realpath.1.html) on
    linux and windows, or
    [grealpath](https://formulae.brew.sh/formula/coreutils) on osx

- If multiple files are selected, they can be sent to the quickfix list
- (optionally) open yazi instead of netrw for directories
- Files that are renamed, moved, or deleted in yazi are kept in sync with open
  buffers in Neovim
  - The files are also kept in sync with currently running LSP servers
- Customizable keybindings
- 🆕 Plugin management for Yazi plugins and flavors
  ([documentation](./documentation/plugin-management.md))

For previewing images with yazi, see Yazi's documentation related to Neovim
[here](https://yazi-rs.github.io/docs/image-preview/#neovim).

## 📦 Installation

First, make sure you have the requirements:

- Neovim 0.10.x or later
- yazi [0.3.0](https://github.com/sxyazi/yazi/releases/tag/v0.3.0) or later
- New features might require a recent version of yazi (see
  [installing-yazi-from-source.md](documentation/installing-yazi-from-source.md))

> [!TIP]
>
> You can run `:checkhealth yazi` to see if compatible versions are installed
> and working.

## ⚙️ Configuration

### Using [lazy.nvim](https://lazy.folke.io/)

This is the preferred installation method.

```lua
---@type LazySpec
{
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory" ,
    },
    {
      -- NOTE: this requires a version of yazi that includes
      -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      '<c-up>',
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
```

Notice that yazi.nvim adds some minimal dependencies for you automatically when
using a plugin manager like lazy.nvim. To see which dependencies are installed,
see [lazy.lua](./lazy.lua). If you are not using lazy.nvim (or
[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim?tab=readme-ov-file)),
you need to install the dependencies yourself. Also see the discussion in
[issue 306](https://github.com/mikavilpas/yazi.nvim/issues/306) and examples of
[other Neovim plugins using this feature](https://github.com/search?q=path%3A%2F%5Elazy%5C.lua%24%2F&type=code).

### Without a package manager

<details>
<summary>Instructions</summary>

If you are not using lazy.nvim, see [lazy.lua](./lazy.lua) for what dependencies
are required.

```lua
-- (Obtain yazi.nvim and its dependencies using your preferred method first)
--
-- Next, map a key to open yazi.nvim
vim.keymap.set("n", "<leader>-", function()
  require("yazi").yazi()
end)
```

</details>

### ⚙️⚙️ Advanced configuration

> [!IMPORTANT]
>
> You don't have to set any of these options. The defaults are fine for most
> users.
>
> For advanced configuration, it's recommended to have your Lua language server
> set up so that you can type check your configuration and avoid errors.
>
> For help on how to do this, there is a section for Neovim development tools in
> the [documentation](./documentation/for-developers/developing.md).

You can optionally configure yazi.nvim by setting any of the options below.

```lua
{
  -- ... other lazy.nvim configuration from above

  ---@type YaziConfig
  opts = {
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

    -- open visible splits as yazi tabs for easy navigation. Requires a yazi
    -- version more recent than 2024-08-11
    -- https://github.com/mikavilpas/yazi.nvim/pull/359
    open_multiple_tabs = false,

    highlight_groups = {
      -- See https://github.com/mikavilpas/yazi.nvim/pull/180
      hovered_buffer = nil,
      -- See https://github.com/mikavilpas/yazi.nvim/pull/351
      hovered_buffer_in_same_directory = nil,
    },

    -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
    floating_window_scaling_factor = 0.9,

    -- the transparency of the yazi floating window (0-100). See :h winblend
    yazi_floating_window_winblend = 0,

    -- the log level to use. Off by default, but can be used to diagnose
    -- issues. You can find the location of the log file by running
    -- `:checkhealth yazi` in Neovim. Also check out the "reproducing issues"
    -- section below
    log_level = vim.log.levels.OFF,

    -- what Neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    open_file_function = function(chosen_file, config, state) end,

    -- customize the keymaps that are active when yazi is open and focused. The
    -- defaults are listed below. Note that the keymaps simply hijack input and
    -- they are never sent to yazi, so only try to map keys that are never
    -- needed by yazi.
    --
    -- Also:
    -- - use e.g. `open_file_in_tab = false` to disable a keymap
    -- - you can customize only some of the keymaps (not all of them)
    -- - you can opt out of all keymaps by setting `keymaps = false`
    keymaps = {
      show_help = '<f1>',
      open_file_in_vertical_split = '<c-v>',
      open_file_in_horizontal_split = '<c-x>',
      open_file_in_tab = '<c-t>',
      grep_in_directory = '<c-s>',
      replace_in_directory = '<c-g>',
      cycle_open_buffers = '<tab>',
      copy_relative_path_to_selected_files = '<c-y>',
      send_to_quickfix_list = '<c-q>',
      change_working_directory = "<c-\\>",
    },

    -- completely override the keymappings for yazi. This function will be
    -- called in the context of the yazi terminal buffer.
    set_keymappings_function = function(yazi_buffer_id, config, context) end,

    -- the type of border to use for the floating window. Can be many values,
    -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
    -- more information, see :h nvim_open_win
    yazi_floating_window_border = 'rounded',

    -- some yazi.nvim commands copy text to the clipboard. This is the register
    -- yazi.nvim should use for copying. Defaults to "*", the system clipboard
    clipboard_register = "*",

    hooks = {
      -- if you want to execute a custom action when yazi has been opened,
      -- you can define it here.
      yazi_opened = function(preselected_path, yazi_buffer_id, config)
        -- you can optionally modify the config for this specific yazi
        -- invocation if you want to customize the behaviour
      end,

      -- when yazi was successfully closed
      yazi_closed_successfully = function(chosen_file, config, state) end,

      -- when yazi opened multiple files. The default is to send them to the
      -- quickfix list, but if you want to change that, you can define it here
      yazi_opened_multiple_files = function(chosen_files, config, state) end,
    },

    -- highlight buffers in the same directory as the hovered buffer
    highlight_hovered_buffers_in_same_directory = true,

    integrations = {
      --- What should be done when the user wants to grep in a directory
      grep_in_directory = function(directory)
        -- the default implementation uses telescope if available, otherwise nothing
      end,
      grep_in_selected_files = function(selected_files)
        -- similar to grep_in_directory, but for selected files
      end,
      --- Similarly, search and replace in the files in the directory
      replace_in_directory = function(directory)
        -- default: grug-far.nvim
      end,
      replace_in_selected_files = function(selected_files)
        -- default: grug-far.nvim
      end,
      -- `grealpath` on OSX, (GNU) `realpath` otherwise
      resolve_relative_path_application = ""
    },
  },
}
```

> [!TIP]
>
> If you are adding custom bindings for special use cases, you can use the lua
> api. It allows customizing the configuration on a per call basis. For example,
> you can open yazi with a different configuration by calling
> `require('yazi').yazi({open_for_directories = true})` to override some of your
> default settings for this specific call.

## ⌨️ Keybindings

These are the default keybindings that are available when yazi is open:

- `<f1>`: show the help menu
- `<c-v>`: open the selected file(s) in vertical splits
- `<c-x>`: open the selected file(s) in horizontal splits
- `<c-t>`: open the selected file(s) in new tabs
- `<c-q>`: send the selected file(s) to the quickfix list
- There are also integrations to other plugins, which you need to install
  separately:
  - `<c-s>`: search in the current yazi directory using
    [telescope](https://github.com/nvim-telescope/telescope.nvim)'s `live_grep`,
    if available.
    - if multiple files/directories are selected in yazi, the search and replace
      will only be done in the selected files/directories
  - `<c-g>`: search and replace in the current yazi directory using
    [grug-far](https://github.com/MagicDuck/grug-far.nvim), if available
    - if multiple files/directories are selected in yazi, the operation is
      limited to those only
  - `<c-y>`: copy the relative path of the selected file(s) to the clipboard.
    Requires GNU `realpath` or `grealpath` on OSX
  - `<tab>`: make yazi jump to the open buffers in Neovim. See
    [#232](https://github.com/mikavilpas/yazi.nvim/pull/232) for more
    information

## 🪛 Customizing yazi

Yazi is highly customizable. It features its own plugin and event system,
themes, and keybindings. This section lists some of the plugins and themes that
I like.

- <https://gitee.com/DreamMaoMao/easyjump.yazi.git> allows jumping to a line by
  typing a hint character, much like
  [hop.nvim](https://github.com/smoka7/hop.nvim)
- <https://github.com/Rolv-Apneseth/starship.yazi> is a port of the
  [starship prompt](https://starship.rs) to yazi. It allows reusing the prompt
  you are using in your shell in yazi.
- <https://github.com/yazi-rs/flavors> houses many of the most popular themes as
  yazi flavors, check it out! They typically also include matching code
  highlighting.

## Contributing

Please see [COMMUNITY.md](./COMMUNITY.md) for more information on the project!

## In case there are issues

See [reproducing-issues.md](./documentation/reproducing-issues.md).
