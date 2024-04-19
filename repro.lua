-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify('./.repro', ':p')

-- set stdpaths to use .repro
for _, name in ipairs({ 'config', 'data', 'state', 'cache' }) do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
end

-- bootstrap lazy
local lazypath = root .. '/plugins/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)
vim.g.mapleader = ' '

-- install plugins
local plugins = {
  'folke/tokyonight.nvim',
  {
    'mikavilpas/yazi.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    event = 'VeryLazy',
    keys = {
      {
        -- 👇 choose your own keymapping
        '<leader>fy',
        function()
          require('yazi').yazi()
        end,

        { desc = 'Open the file manager' },
      },
    },
    opts = {
      open_for_directories = false,
    },
  },
}
require('lazy').setup(plugins, {
  root = root .. '/plugins',
})

vim.cmd.colorscheme('tokyonight')
-- add anything else here
