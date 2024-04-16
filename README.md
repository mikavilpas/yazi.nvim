# 🎲 A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<a href="https://dotfyle.com/plugins/mikavilpas/yazi.nvim">
  <img src="https://dotfyle.com/plugins/mikavilpas/yazi.nvim/shield?style=flat-square" alt="shield image for plugin usage" />
</a>

Yazi is a blazing fast file manager for the terminal. This plugin allows you to open yazi in a floating window in neovim.

<https://github.com/mikavilpas/yazi.nvim/assets/300791/c7ff98ee-54d6-4ad0-9318-903e4b674f84>

## ✨ Features

- Open yazi in a floating window
- Files can be opened in the current buffer, a vertical split, a horizontal split, or a new tab
- If multiple files are selected, they can be sent to the quickfix list
- (optionally) open yazi instead of netrw for directories
- Files renamed in yazi are kept in sync with open buffers
- Customizable keybindings

## 📦 Installation

First, make sure you have the requirements:

- neovim 0.9.x or later
- yazi 0.2.4 or later. For the best experience, use a version released after 2024-04-06 that includes [this](https://github.com/sxyazi/yazi/pull/880) change

> You can run `:checkhealth yazi` to see if compatible versions are installed and working.

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
    {
      -- 👇 choose your own keymapping
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      { desc = "Open the file manager" },
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
  },
}
```

### Advanced configuration

> You don't have to set any of these options. The defaults are fine for most users.

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

    -- the path to a temporary file that will be created by yazi to store the
    -- chosen file path. This is used internally but you might want to change
    -- it if there are issues accessing the default path.
    chosen_file_path = '/tmp/yazi_filechosen',

    -- the path to a temporary file that will be created by yazi to store
    -- events
    events_file_path = '/tmp/yazi.nvim.events.txt',

    -- what neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    open_file_function = function(chosen_file, config) end,

    -- completely override the keymappings for yazi. This function will be
    -- called in the context of the yazi terminal buffer.
    set_keymappings_function = function(yazi_buffer_id, config) end,

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
      yazi_opened_multiple_files = function(chosen_files, config) end,
    },
  },
}
```

## ⌨️ Keybindings

These are the default keybindings that are available when yazi is open:

- `<c-v>`: open the selected file in a vertical split
- `<c-x>`: open the selected file in a horizontal split
- `<c-t>`: open the selected file in a new tab

Notice that these are also the defaults for telescope.

## 🪛 Customizing yazi

Yazi is highly customizable. It features its own plugin and event system, themes, and keybindings. This section lists some of the plugins and themes that I like.

- <https://github.com/DreamMaoMao/keyjump.yazi> allows jumping to a line by
  typing a hint character, much like
  [hop.nvim](https://github.com/smoka7/hop.nvim)
- <https://github.com/Rolv-Apneseth/starship.yazi> is a port of the
  [starship prompt](https://starship.rs) to yazi. It allows reusing the prompt
  you are using in your shell in yazi.
- <https://github.com/catppuccin/yazi> ports the catppuccin theme to yazi.
- <https://github.com/catppuccin/bat> can be used to change the syntax highlighting theme yazi uses to preview files. See [this discussion](https://github.com/sxyazi/yazi/discussions/818) or [my config](https://github.com/mikavilpas/dotfiles/commit/bb07515f69d219fd3435d222fcb2d80d27a25025#diff-973b37f40e024ca0f7e62f2569efce24ad550d0352adc8449168ac950af9eaf5R8) for an example of using it

## 🍴 About my fork

I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use, and also because I wanted to learn neovim plugin development.

So far I have done some maintenance work and added a bunch of features:

- chore: removed unused code
- feat: yazi pre-selects the current file when opened
- test: add simple testing setup for future development
- feat: can optionally open yazi instead of netrw for directories
- feat: health check for yazi
- feat: files that are renamed, moved, deleted, or trashed in yazi are kept in sync with open buffers (this requires a version of yazi that includes [this](https://github.com/sxyazi/yazi/pull/880) change from 2024-04-06)
- feat: allow customizing the method of opening the selected file in neovim
- feat: can send multiple opened files to the quickfix list
- feat: can open a file in a vertical split
- feat: can open a file in a horizontal split
- feat: can open a file in a new tab

If you'd like to collaborate, contact me via GitHub issues.
