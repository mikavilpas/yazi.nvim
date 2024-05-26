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
---     require("yazi.plugin").build_plugin(plugin)
---   end,
--- }
--- ```
---
--- For more information, see the yazi.nvim documentation.
---
---@param plugin YaziLazyNvimPlugin
---@param options? { yazi_dir: string }
---@return YaziPluginInstallationResultSuccess | YaziPluginInstallationResultFailure
function M.build_plugin(plugin, options)
  local yazi_dir = options and options.yazi_dir
    or vim.fn.expand('~/.config/yazi')
  local to = vim.fs.normalize(vim.fs.joinpath(yazi_dir, 'plugins', plugin.name))

  local dir = vim.loop.fs_stat(plugin.dir)
  if dir == nil or dir.type ~= 'directory' then
    ---@type YaziPluginInstallationResultFailure
    local result = {
      error = 'plugin directory does not exist',
      from = plugin.dir,
      message = 'yazi.nvim: failed to install plugin',
    }
    vim.notify(vim.inspect(result))
    return result
  end

  local success, error = vim.uv.fs_symlink(plugin.dir, to)

  if not success then
    ---@type YaziPluginInstallationResultFailure
    local result = {
      message = 'yazi.nvim: failed to install plugin',
      from = plugin.dir,
      to = to,
      error = error or 'unknown error',
    }
    vim.notify(vim.inspect(result))

    return result
  end

  ---@type YaziPluginInstallationResultSuccess
  local result = {
    message = 'yazi.nvim: successfully installed plugin ' .. plugin.name,
    from = plugin.dir,
    to = to,
  }

  vim.notify(vim.inspect(result))
  return result
end

--- Represents information about the plugin to install. Note that this is
--- compatible with LazyPlugin, the lazy.nvim plugin specification table, so
--- you can just pass that.
---@alias YaziLazyNvimPlugin { name: string, dir: string }

---@alias YaziPluginInstallationResultSuccess { message: string, from: string, to: string }
---@alias YaziPluginInstallationResultFailure { message: string, from: string, to?: string, error: string }

return M
