---@module "yazi"

require("yazi").setup(
  ---@type YaziConfig
  {
    future_features = {
      yazi_plugin_keymaps = {
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        cycle_open_buffers = "<tab>",
      },
    },
  }
)

-- Make the bundled `nvim.yazi` plugin available to yazi by symlinking it into
-- yazi's plugin directory. An absolute path (derived from the repo root) avoids
-- the fragile relative symlinks that break when the test directory is
-- materialized into a temporary location.
-- selene: allow(global_usage)
require("yazi.plugin").build_plugin({
  name = "nvim.yazi",
  source = vim.fn.expand("~/.config/yazi/plugins"),
  dir = vim.fs.joinpath(_G.yazi_nvim_repo_root, "nvim.yazi"),
}, { silent = true })
