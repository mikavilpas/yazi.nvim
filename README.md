# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<https://github.com/mikavilpas/yazi.nvim/assets/300791/4640cb54-efad-47b5-9157-735e78bf0c43>

I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use.

So far I have done some maintenance work:

- chore: removed unused code
- feat: yazi pre-selects the current file when opened
- test: add simple testing setup for future development
- feat: can optionally open yazi instead of netrw for directories

If you'd like to collaborate, contact me via GitHub issues.

## Installation

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
    -- enable this if you want to open yazi instead of netrw
    open_for_directories = false,
  },
}
```
