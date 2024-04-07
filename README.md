# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<https://github.com/mikavilpas/yazi.nvim/assets/300791/4640cb54-efad-47b5-9157-735e78bf0c43>

I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use.

So far I have done some maintenance work:

- chore: removed unused code
- feat: yazi pre-selects the current file when opened
- test: add simple testing setup for future development
- feat: can optionally open yazi instead of netrw for directories
- feat: health check for yazi
- feat: files renamed in yazi are kept in sync with open buffers

If you'd like to collaborate, contact me via GitHub issues.

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
    events_file_path = '/tmp/yazi.nvim.events.txt'
  },
}
```
