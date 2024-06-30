-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.
--
--https://lazy.folke.io/packages#lazy

---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  { 'nvim-lua/plenary.nvim', lazy = true },
  {
    'mikavilpas/yazi.nvim',
    ---@type YaziConfig
    opts = {},
  },
}
