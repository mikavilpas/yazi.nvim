local M = {}

--- A specification that represents information about the plugin or flavor to
--- install. Note that this is compatible with LazyPlugin, the lazy.nvim plugin
--- specification table, so you can just pass that.
---@alias YaziLazyNvimSpec { name: string, dir: string }

---@alias YaziSpecInstallationResultSuccess { message: string, from: string, to: string }
---@alias YaziSpecInstallationResultFailure { message: string, from: string, to?: string, error: string }

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
---@param plugin YaziLazyNvimSpec
---@param options? { yazi_dir: string }
function M.build_plugin(plugin, options)
  local yazi_dir = options and options.yazi_dir
    or vim.fn.expand('~/.config/yazi')

  local yazi_plugins_dir = vim.fn.expand(vim.fs.joinpath(yazi_dir, 'plugins'))
  ---@cast yazi_plugins_dir string
  vim.fn.mkdir(yazi_plugins_dir, 'p')

  local to = vim.fs.normalize(vim.fs.joinpath(yazi_plugins_dir, plugin.name))

  return M.symlink(plugin, to)
end

---@param flavor YaziLazyNvimSpec
---@param options? { yazi_dir: string }
function M.build_flavor(flavor, options)
  local yazi_dir = options and options.yazi_dir
    or vim.fn.expand('~/.config/yazi')

  local yazi_flavors_dir = vim.fn.expand(vim.fs.joinpath(yazi_dir, 'flavors'))
  ---@cast yazi_flavors_dir string
  vim.fn.mkdir(yazi_flavors_dir, 'p')

  local to = vim.fs.normalize(vim.fs.joinpath(yazi_flavors_dir, flavor.name))

  return M.symlink(flavor, to)
end

--- A general implementation of a symlink operation. For yazi plugins and
--- flavors, prefer using `build_plugin` and `build_flavor` instead.
---@param spec YaziLazyNvimSpec
---@param to string
---@return YaziSpecInstallationResultSuccess | YaziSpecInstallationResultFailure
function M.symlink(spec, to)
  local dir = vim.uv.fs_stat(spec.dir)
  if dir == nil or dir.type ~= 'directory' then
    ---@type YaziSpecInstallationResultFailure
    local result = {
      error = 'yazi plugin/flavor directory does not exist',
      from = spec.dir,
      message = 'yazi.nvim: failed to install',
    }
    vim.notify(vim.inspect(result))
    return result
  end

  local success, error = vim.uv.fs_symlink(spec.dir, to)

  if not success then
    ---@type YaziSpecInstallationResultFailure
    local result = {
      message = 'yazi.nvim: failed to install',
      from = spec.dir,
      to = to,
      error = error or 'unknown error',
    }
    vim.notify(vim.inspect(result))

    return result
  end

  ---@type YaziSpecInstallationResultSuccess
  local result = {
    message = 'yazi.nvim: successfully installed ' .. spec.name,
    from = spec.dir,
    to = to,
  }

  vim.notify(vim.inspect(result))
  return result
end

return M
