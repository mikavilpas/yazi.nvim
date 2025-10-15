-- renovate: datasource=github-releases depName=folke/lazy.nvim
local lazy_version = "v11.17.1"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=" .. lazy_version,
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

-- uncomment to debug lsp things. Details will be available in the following
-- files:
-- - yazi.nvim/integration-tests/test-environment/testdirs/dir-spyjPG/.local/state/nvim/lsp.log
-- - yazi.nvim/integration-tests/test-environment/.repro/data/emmylua_ls/logs
-- vim.lsp.set_log_level("debug")

-- for CI, use a single log file location and put it in a known location. This
-- way it's easy to display the log file contents after each test using
-- showYaziLog() and removeYaziLog().
vim.env.YAZI_NVIM_LOG_PATH =
  vim.fn.fnamemodify(vim.uv.os_environ().HOME .. "/../../.repro/yazi.log", ":p")

local plugins = require("plugins")
vim.list_extend(plugins, {
  {
    "mikavilpas/yazi.nvim",
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
      -- use different register than the system clipboard for yanking, so that
      -- the developers can work on the code while the tests run without any
      -- disturbances
      clipboard_register = '"',
      -- allows logging debug data, which can be shown in CI when cypress tests fail
      log_level = vim.log.levels.DEBUG,
      future_features = {},
    },
  },
})

require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
do
  local colors = require("catppuccin.palettes").get_palette("macchiato")
  vim.api.nvim_set_hl(
    0,
    "SnacksPickerPickWin",
    { bg = colors.peach, fg = "#000000" }
  )
end
