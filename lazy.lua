-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.
--
-- If you are curious about how exactly the plugins are used, you can use e.g.
-- the search functionality on Github.
--
--https://lazy.folke.io/packages#lazy

---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  -- Needed for file path resolution mainly
  --
  -- https://github.com/nvim-lua/plenary.nvim/
  { "nvim-lua/plenary.nvim", lazy = true },
  -- { "folke/snacks.nvim", lazy = true },

  --
  -- TODO enable after https://github.com/nvim-neorocks/nvim-busted-action/issues/4 is resolved
  --
  -- {
  --   -- Neovim plugin that adds support for file operations using built-in LSP
  --   -- https://github.com/antosha417/nvim-lsp-file-operations
  --   'antosha417/nvim-lsp-file-operations',
  --   lazy = true,
  -- },

  {
    "mikavilpas/yazi.nvim",
    ---@type YaziConfig | {}
    opts = {},
    cmd = {
      "Yazi",
      "Yazi cwd",
      "Yazi toggle",
    },
  },
}
