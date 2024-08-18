-- This files defines how to initialize the test environment for the
-- integration tests. It should be executed before running the tests.

---@module "lazy"
---@module "yazi"
---@module "catppuccin"

-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.repro", ":p")
vim.env.LAZY_STDPATH = ".repro"

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v11.14.1",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.rtp:prepend("../../")

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.swapfile = false

-- install the following plugins
---@type LazySpec
local plugins = {
  {
    "mikavilpas/yazi.nvim",
    -- for tests, always use the code from this repository
    dir = "../..",
    event = "VeryLazy",
    keys = {
      { "<up>", "<cmd>Yazi<cr>" },
      { "<c-up>", "<cmd>Yazi toggle<cr>" },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
      -- use different register than the system clipboard for yanking, so that
      -- the developers can work on the code while the tests run without any
      -- disturbances
      clipboard_register = '"',
      -- allows logging debug data, which can be shown in CI when cypress tests fail
      log_level = vim.log.levels.DEBUG,
      integrations = {
        grep_in_directory = function(directory)
          require("telescope.builtin").live_grep({
            -- disable previewer to be able to see the full directory name. The
            -- tests can make assertions on this path.
            previewer = false,
            search = "",
            prompt_title = "Grep in " .. directory,
            cwd = directory,
          })
        end,
      },
    },
  },
  { "nvim-telescope/telescope.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "https://github.com/MagicDuck/grug-far.nvim", opts = {} },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
