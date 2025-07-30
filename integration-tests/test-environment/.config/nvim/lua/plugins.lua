_G.yazi_nvim_repo_root =
  vim.fn.fnamemodify(vim.uv.os_environ().HOME, ":h:h:h:h")

-- install the following plugins
---@module "lazy"
---@type LazySpec
local plugins = {
  {
    "mikavilpas/yazi.nvim",
    -- for tests, always use the code from this repository
    dir = _G.yazi_nvim_repo_root,
    event = "VeryLazy",
    keys = {
      { "<up>", mode = { "n", "v" }, "<cmd>Yazi<cr>" },
      { "<c-up>", "<cmd>Yazi toggle<cr>" },
    },
    ---@type YaziConfig
    opts = {},
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}

return plugins
