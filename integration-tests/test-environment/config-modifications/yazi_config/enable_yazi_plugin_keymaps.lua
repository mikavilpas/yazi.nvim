---@module "yazi"

require("yazi").setup(
  ---@type YaziConfig
  {
    future_features = {
      yazi_plugin_keymaps = {
        open_file_in_vertical_split = "<c-v>",
      },
    },
  }
)

-- Make the bundled `nvim.yazi` plugin available to yazi by symlinking it into
-- yazi's plugin directory. An absolute path (derived from the repo root) avoids
-- the fragile relative symlinks that break when the test directory is
-- materialized into a temporary location.
-- selene: allow(global_usage)
local repo_root = _G.yazi_nvim_repo_root
  or vim.fn.fnamemodify(vim.uv.os_environ().HOME, ":h:h:h:h")

local plugin_source = vim.fs.joinpath(repo_root, "nvim.yazi")
local yazi_plugins_dir = vim.fn.expand("~/.config/yazi/plugins")
vim.fn.mkdir(yazi_plugins_dir, "p")

local link = vim.fs.joinpath(yazi_plugins_dir, "nvim.yazi")
local existing = vim.uv.fs_lstat(link)
if existing and existing.type == "link" then
  vim.uv.fs_unlink(link)
end
vim.uv.fs_symlink(plugin_source, link)
