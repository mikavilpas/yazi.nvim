-- renovate: datasource=github-releases depName=folke/lazy.nvim
local lazy_version = "v11.17.5"

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
      integrations = {
        grep_in_directory = "telescope",
        picker_add_copy_relative_path_action = "snacks.picker",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    -- renovate: datasource=git-refs-master packageName=https://github.com/nvim-telescope/telescope.nvim
    commit = "3333a52ff548ba0a68af6d8da1e54f9cd96e9179",
    lazy = true,
    opts = {
      pickers = {
        live_grep = {
          theme = "dropdown",
        },
      },
    },
  },
  {
    "https://github.com/ibhagwan/fzf-lua",
    -- renovate: datasource=git-refs packageName=https://github.com/ibhagwan/fzf-lua
    commit = "19d7020b700879759d7f834fc717dde086f673a7",
  },
  {
    "https://github.com/MagicDuck/grug-far.nvim",
    -- renovate: datasource=git-refs packageName=https://github.com/MagicDuck/grug-far.nvim
    commit = "74eef260e1142264ab994fb9c88e4f420e9486d7",
    opts = {},
  },

  {
    "folke/snacks.nvim",
    -- renovate: datasource=github-releases depName=folke/snacks.nvim
    version = "v2.30.0",
    priority = 1000,
    lazy = false,
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<C-y>"] = { "yazi_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader><space>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart Find Files",
      },
    },
  },

  {
    -- https://github.com/mason-org/mason-lspconfig.nvim?tab=readme-ov-file#recommended-setup-for-lazynvim
    "mason-org/mason-lspconfig.nvim",
    -- renovate: datasource=github-releases depName=mason-org/mason-lspconfig.nvim
    version = "v2.1.0",
    opts = {},
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("mason-lspconfig").setup({
        -- make sure mason-lspconfig does not automatically enable any LSP
        -- servers that might be installed on the system. We want to only use the
        -- LSP servers that are included in the test setup.
        automatic_enable = false,
      })
      vim.lsp.config("emmylua_ls", {
        root_markers = {
          -- The default config prefers a `luarc.json` file which is found at
          -- the root of the yazi.nvim repository. Here we need to find the
          -- file inside the test environment instead, so that the tests can
          -- run in isolation.
          --
          -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/emmylua_ls.lua
          ".emmyrc.json",
        },
      })
      vim.lsp.enable("emmylua_ls")
    end,
    dependencies = {
      {
        "https://github.com/mason-org/mason.nvim",
        opts = {},
        -- renovate: datasource=github-releases depName=mason-org/mason.nvim
        version = "v2.1.0",
      },
      {
        "neovim/nvim-lspconfig",
        -- renovate: datasource=github-releases depName=neovim/nvim-lspconfig
        version = "v2.5.0",
      },
    },
  },
} --[[@as LazySpec[][]])

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
