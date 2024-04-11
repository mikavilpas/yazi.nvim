# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<https://github.com/mikavilpas/yazi.nvim/assets/300791/4640cb54-efad-47b5-9157-735e78bf0c43>

## Features

- Open yazi in a floating window
- (optionally) open yazi instead of netrw for directories
- yazi pre-selects the current file when opened
- Files renamed in yazi are kept in sync with open buffers

## Installation

> **Note:** This plugin requires a recent version of yazi.
> You can run `:checkhealth yazi` to see if a compatible version is installed and working.

Using lazy.nvim:

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
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      { desc = "Open the file manager" },
    },
  },
  ---@type YaziConfig
  opts = {
    -- Below is the default configuration. It is optional to set these values.
    --

    -- enable this if you want to open yazi instead of netrw
    open_for_directories = false,

    -- the path to a temporary file that will be created by yazi to store the
    -- chosen file path
    chosen_file_path = '/tmp/yazi_filechosen',

    -- the path to a temporary file that will be created by yazi to store
    -- events
    events_file_path = '/tmp/yazi.nvim.events.txt',

    -- what neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    -- If you want to open it in a split / new tab, you can define it here.
    open_file_function = function(chosen_file) end,

    hooks = {
      -- if you want to execute a custom action when yazi has been opened,
      -- you can define it here
      yazi_opened = function(preselected_path) end,

      -- when yazi was successfully closed
      yazi_closed_successfully = function(chosen_file) end,

      -- when yazi opened multiple files. The default is to send them to the
      -- quickfix list, but if you want to change that, you can define it here
      yazi_opened_multiple_files = function(chosen_files) end,
    },

    -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
    floating_window_scaling_factor = 0.9,

    -- the winblend value for the floating window. See :h winblend
    yazi_floating_window_winblend = 0,
  },
}
```

## About my fork

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

If you'd like to collaborate, contact me via GitHub issues.
