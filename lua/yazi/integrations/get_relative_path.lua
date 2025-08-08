local M = {}

---@param config YaziConfig
---@param relative_path_arguments YaziGetRelativePathImplementationArguments
function M.get_relative_path(config, relative_path_arguments)
  ---@param arguments YaziGetRelativePathImplementationArguments
  local default_get_relative_path = function(arguments)
    return require("yazi.utils").relative_path(
      config.integrations.resolve_relative_path_application,
      arguments
    )
  end

  ---@type string | nil
  local relative_path

  if config.integrations.resolve_relative_path_implementation ~= nil then
    relative_path = config.integrations.resolve_relative_path_implementation(
      relative_path_arguments,
      default_get_relative_path
    )
  else
    relative_path = default_get_relative_path(relative_path_arguments)
  end

  assert(
    relative_path ~= nil,
    "Could not resolve relative path for "
      .. vim.inspect(relative_path_arguments)
  )
  return relative_path
end

return M
