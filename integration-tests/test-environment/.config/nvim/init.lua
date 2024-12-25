-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v11.16.0",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.swapfile = false

local thisfile = vim.fn.expand("<sfile>")
local repo_root = vim.fn.fnamemodify(thisfile, ":h:h:h:h:h:h:h")

-- for CI, use a single log file location and put it in a known location. This
-- way it's easy to display the log file contents after each test using
-- showYaziLog() and removeYaziLog().
vim.env.YAZI_NVIM_LOG_PATH =
  vim.fn.fnamemodify(vim.uv.os_environ().HOME .. "/../../.repro/yazi.log", ":p")

-- install the following plugins
---@module "lazy"
---@type LazySpec
local plugins = {
  {
    "mikavilpas/yazi.nvim",
    -- for tests, always use the code from this repository
    dir = repo_root,
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
      future_features = {
        ya_emit_open = true,
      },
      integrations = {
        grep_in_directory = "telescope",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    opts = {
      pickers = {
        live_grep = {
          theme = "dropdown",
        },
      },
    },
  },
  { "ibhagwan/fzf-lua" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "https://github.com/MagicDuck/grug-far.nvim", opts = {} },
  { "folke/snacks.nvim", opts = {} },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
