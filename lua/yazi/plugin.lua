local M = {}

--- Helper utility for compatibility with
--- [lazy.nvim](https://github.com/folke/lazy.nvim).
---
--- Example usage:
---
--- ```lua
--- ---@type LazyPlugin
--- {
---   "Rolv-Apneseth/starship.yazi",
---   lazy = true,
---   build = function(plugin)
---     -- this will be called by lazy.nvim after the plugin was updated
---     require("yazi.plugin").build(plugin)
---   end,
--- }
--- ```
---
--- For more information, see the yazi.nvim documentation.
---
---@param plugin YaziLazyNvimPlugin
---@param options? { yazi_dir: string }
function M.build_plugin(plugin, options)
  local yazi_dir = options and options.yazi_dir
    or vim.fn.expand('~/.config/yazi')
  local to = vim.fs.normalize(vim.fs.joinpath(yazi_dir, 'plugins', plugin.name))

  if not vim.fn.isdirectory(plugin.dir) then
    vim.notify(
      vim.inspect({ 'yazi.nvim: plugin directory does not exist', plugin.dir })
    )
    return
  end

  vim.notify(
    vim.inspect({ 'yazi.nvim: installing plugin', from = plugin.dir, to = to })
  )
  vim.uv.fs_symlink(plugin.dir, to)
end

--- Represents information about the plugin to install. Note that this is
--- compatible with LazyPlugin, the lazy.nvim plugin specification table, so
--- you can just pass that.
---@alias YaziLazyNvimPlugin { name: string, dir: string }

return M
