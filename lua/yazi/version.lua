local M = {}

-- https://www.reddit.com/r/neovim/comments/tk1hby/get_the_path_to_the_current_lua_script_in_neovim/
local function is_win()
  return package.config:sub(1, 1) == '\\'
end

local function get_path_separator()
  if is_win() then
    return '\\'
  end
  return '/'
end

local function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. get_path_separator() .. ')')
end

function M.yazi_version_file_path()
  local me = script_path()
  local relative_path = vim.fs.normalize(
    vim.fs.joinpath(me, '..', '..', '.release-please-manifest.json')
  )
  local absolute_path = vim.fn.fnamemodify(relative_path, ':p')
  return absolute_path
end

function M.yazi_nvim_version()
  local success, result = pcall(function()
    local lines = vim.fn.readfile(M.yazi_version_file_path())
    local manifest = table.concat(lines, '')
    local json = vim.json.decode(manifest)
    local version = json['.']
    assert(type(version) == 'string')

    return version
  end)

  if success then
    return result
  end
end

return M
