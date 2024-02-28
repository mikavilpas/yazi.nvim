# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)
I forked this from <https://github.com/DreamMaoMao/yazi.nvim> for my own use.

So far I have done some maintenance work:
- chore: removed unused code
- feat: yazi pre-selects the current file when opened

If you'd like to collaborate, contact me via GitHub issues.


# install

```
 {
  "sp3ctum/yazi.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },

  keys = {
    { "<leader>-", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
  },
}
```

