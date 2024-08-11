---@module "yazi"

-- The reason to set a different yazi.nvim help key is that Cypress, the
-- current test runner, does not natively support function keys such as <f1>
-- https://docs.cypress.io/api/commands/type#Arguments

require("yazi").setup(
  ---@type YaziConfig
  {
    keymaps = {
      show_help = "<del>",
    },
  }
)
