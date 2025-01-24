---@module "yazi"

require("yazi").setup(
  ---@type YaziConfig
  {
    integrations = {
      grep_in_selected_files = "snacks.picker",
      grep_in_directory = "snacks.picker",
    },
  }
)
