-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.
--
--https://lazy.folke.io/packages#lazy

---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  { 'nvim-lua/plenary.nvim', lazy = true },
  { 'akinsho/bufferline.nvim', lazy = true },
  {
    -- Neovim plugin that adds support for file operations using built-in LSP
    -- https://github.com/antosha417/nvim-lsp-file-operations
    'antosha417/nvim-lsp-file-operations',
    lazy = true,
  },
  {
    'mikavilpas/yazi.nvim',
    ---@type YaziConfig
    opts = {},
  },
}
