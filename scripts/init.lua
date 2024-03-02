-- This sets up a minimal environment for lazy.nvim to work in.
-- It is used to install, configure and activate the plugins that are required for testing.
-- Adapted from https://github.com/folke/lazy.nvim/blob/main/.github/ISSUE_TEMPLATE/bug_report.yml?plain=1
local root = vim.fn.expand('%:p:h')

local dep_dir = root .. '/development_dependencies/'

-- set stdpaths
for _, name in ipairs({ 'config', 'data', 'state', 'cache' }) do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = dep_dir .. '/' .. name
end

-- bootstrap lazy
local lazypath = root .. '/scripts/lazy.nvim'

vim.opt.runtimepath:prepend(lazypath)

-- install plugins
---@type LazyConfig
local plugins = {
  'folke/tokyonight.nvim',
  'nvim-lua/plenary.nvim',
  {
    -- configuration copied from
    -- https://www.lazyvim.org/plugins/treesitter
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    event = { 'VeryLazy' },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
  },
  -- add any other plugins here
}
require('lazy').setup(plugins, {
  root = dep_dir .. '/plugins',
  lockfile = root .. '/lazy-lock.json',
})

vim.cmd.colorscheme('tokyonight')
-- add anything else here
