-- This files defines how to initialize the test environment for the
-- integration tests. It should be executed before running the tests.

---@module "lazy"
---@module "yazi"
---@module "catppuccin"

-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify('./.repro', ':p')

-- set stdpaths to use .repro
for _, name in ipairs({ 'config', 'data', 'state', 'cache' }) do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- install the following plugins
---@type LazySpec
local plugins = {
  {
    'mikavilpas/yazi.nvim',
    dir = '../../',
    event = 'VeryLazy',
    keys = {
      {
        '<up>',
        function()
          require('yazi').yazi()
        end,
      },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
    },
  },
  { 'nvim-telescope/telescope.nvim', lazy = true },
  { 'nvim-lua/plenary.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
}
require('lazy').setup({ spec = plugins })

vim.cmd.colorscheme('catppuccin-macchiato')
