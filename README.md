# 🎲 A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<a href="https://dotfyle.com/plugins/mikavilpas/yazi.nvim">
  <img src="https://dotfyle.com/plugins/mikavilpas/yazi.nvim/shield?style=flat-square" alt="shield image for plugin usage" /> </a>

[![Type checked codebase](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml/badge.svg)](https://github.com/mikavilpas/yazi.nvim/actions/workflows/typecheck.yml)

Yazi is a blazing fast file manager for the terminal. This plugin allows you to
open yazi in a floating window in Neovim.

<https://github.com/mikavilpas/yazi.nvim/assets/300791/c7ff98ee-54d6-4ad0-9318-903e4b674f84>

## ✨ Features

- Open yazi in a floating window
- Files can be selected in yazi and opened in the current buffer, a vertical
  split, a horizontal split, or a new tab
- If multiple files are selected, they can be sent to the quickfix list
- (optionally) open yazi instead of netrw for directories
- Files that are renamed, moved, or deleted in yazi are kept in sync with open
  buffers in Neovim
  - The files are also kept in sync with currently running LSP servers
- Customizable keybindings
- 🆕 Plugin manager for Yazi plugins
  ([documentation](./documentation/plugin-manager.md)). Please provide your
  feedback!

## 📦 Installation

First, make sure you have the requirements:

- Neovim 0.10.x or later
- yazi [0.2.5](https://github.com/sxyazi/yazi/releases/tag/v0.2.5) or later

> You can run `:checkhealth yazi` to see if compatible versions are installed
> and working.

## ⚙️ Configuration

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
---@type LazySpec
{
  "mikavilpas/yazi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      desc = "Open the file manager",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open the file manager in nvim's working directory" ,
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
  },
}
```

### ⚙️⚙️ Advanced configuration

> You don't have to set any of these options. The defaults are fine for most
> users.
>
> For advanced configuration, it's recommended to have your Lua language server
> set up so that you can type check your configuration and avoid errors.

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
    open_for_directories = false,

    -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
    floating_window_scaling_factor = 0.9,

    -- the transparency of the yazi floating window (0-100). See :h winblend
    yazi_floating_window_winblend = 0,

    -- what Neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    open_file_function = function(chosen_file, config) end,

    -- completely override the keymappings for yazi. This function will be
    -- called in the context of the yazi terminal buffer.
    set_keymappings_function = function(yazi_buffer_id, config) end,

    -- the type of border to use for the floating window. Can be many values,
    -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
    -- more information, see :h nvim_open_win
    yazi_floating_window_border = 'rounded',

    hooks = {
      -- if you want to execute a custom action when yazi has been opened,
      -- you can define it here.
      yazi_opened = function(preselected_path, yazi_buffer_id, config)
        -- you can optionally modify the config for this specific yazi
        -- invocation if you want to customize the behaviour
      end,

      -- when yazi was successfully closed
      yazi_closed_successfully = function(chosen_file, config) end,

      -- when yazi opened multiple files. The default is to send them to the
      -- quickfix list, but if you want to change that, you can define it here
      yazi_opened_multiple_files = function(chosen_files, config, state) end,
    },

    integrations = {
      --- What should be done when the user wants to grep in a directory
      ---@param directory string
      grep_in_directory = function(directory)
        -- the default implementation uses telescope if available, otherwise nothing
      end,
    },
  },
}
```

## ⌨️ Keybindings

These are the default keybindings that are available when yazi is open:

- `<c-v>`: open the selected file in a vertical split
- `<c-x>`: open the selected file in a horizontal split
- `<c-t>`: open the selected file in a new tab
- `<c-s>`: close the current yazi directory using
  [telescope](https://github.com/nvim-telescope/telescope.nvim)'s `live_grep`.
  If telescope is not available, nothing happens. You can customize the search
  action in your configuration.

Notice that these are also the defaults for telescope.

## 🪛 Customizing yazi

Yazi is highly customizable. It features its own plugin and event system,
themes, and keybindings. This section lists some of the plugins and themes that
I like.

- <https://github.com/DreamMaoMao/keyjump.yazi> allows jumping to a line by
  typing a hint character, much like
  [hop.nvim](https://github.com/smoka7/hop.nvim)
- <https://github.com/Rolv-Apneseth/starship.yazi> is a port of the
  [starship prompt](https://starship.rs) to yazi. It allows reusing the prompt
  you are using in your shell in yazi.
- <https://github.com/catppuccin/yazi> ports the catppuccin theme to yazi.
- <https://github.com/catppuccin/bat> can be used to change the syntax
  highlighting theme yazi uses to preview files. See
  [this discussion](https://github.com/sxyazi/yazi/discussions/818) or
  [my config](https://github.com/mikavilpas/dotfiles/commit/bb07515f69d219fd3435d222fcb2d80d27a25025#diff-973b37f40e024ca0f7e62f2569efce24ad550d0352adc8449168ac950af9eaf5R8)
  for an example of using it

## 🍴 About my fork

I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use,
and also because I wanted to learn Neovim plugin development.

## Contributing

Please see [COMMUNITY.md](./COMMUNITY.md) for more information on the project!
