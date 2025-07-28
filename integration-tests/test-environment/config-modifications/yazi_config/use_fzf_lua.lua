---@module "yazi"

require("yazi").setup(
  ---@type YaziConfig
  {
    integrations = {
      grep_in_selected_files = "fzf-lua",
      grep_in_directory = "fzf-lua",
    },
  }
)
