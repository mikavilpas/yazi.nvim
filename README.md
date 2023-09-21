# A Neovim Plugin for [yazi](https://github.com/sxyazi/yazi.git)
Disclaimer: I straight-up copied most of the code in this plugin from lazygit.nvim because I just wanted something working asap. The only reason I didn't fork lazygit.nvim but made a new repository instead was because this is plugin for a completely different purpose (not for using Lazygit). I want to give credits to the author of lazygit.nvim for writing awesome code and thank him for using the MIT licence.


https://github.com/DreamMaoMao/yazi.nvim/assets/30348075/bb16d6e7-1628-4bde-9e84-d81acf0fe382



# install

```
 {
  "DreamMaoMao/yazi.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },

  keys = {
    { "<leader>gy", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
  },
}
```

### Usage
```
:Yazi

or 

leader + gy
```

