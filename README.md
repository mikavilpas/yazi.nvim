# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)

<https://github.com/sp3ctum/yazi.nvim/assets/300791/4640cb54-efad-47b5-9157-735e78bf0c43>

I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use.

So far I have done some maintenance work:

- chore: removed unused code
- feat: yazi pre-selects the current file when opened
- test: add simple testing setup for future development

If you'd like to collaborate, contact me via GitHub issues.

## Installation

Using lazy.nvim:

```lua
---@type LazySpec
{
  "sp3ctum/yazi.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  cmd = "Yazi",
  keys = {
    { "<leader>-", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
  },
}
```
