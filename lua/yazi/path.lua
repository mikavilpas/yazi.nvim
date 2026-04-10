---@class YaziPath
---@field filename string
local YaziPath = {}
YaziPath.__index = YaziPath

--- Create a new path object from a string.
--- Compatible with plenary.path's Path:new() interface.
---@param path string
---@return YaziPath
function YaziPath:new(path)
  local instance = setmetatable({}, self)
  -- normalize: remove trailing slash unless it's the root "/"
  if #path > 1 and path:sub(-1) == "/" then
    path = path:sub(1, -2)
  end
  instance.filename = path
  return instance
end

---@return YaziPath
function YaziPath:parent()
  local dir = vim.fs.dirname(self.filename)
  return YaziPath:new(dir)
end

--- Return all ancestor directories as a list of strings (not Path objects).
--- This matches plenary.path's :parents() which returns string[].
---@return string[]
function YaziPath:parents()
  local result = {}
  local current = self.filename
  while true do
    local dir = vim.fs.dirname(current)
    if dir == current then
      break
    end
    result[#result + 1] = dir
    current = dir
  end
  return result
end

---@return boolean
function YaziPath:is_dir()
  return vim.fn.isdirectory(self.filename) == 1
end

---@return boolean
function YaziPath:is_file()
  local stat = vim.uv.fs_stat(self.filename)
  return stat ~= nil and stat.type == "file"
end

---@return boolean
function YaziPath:exists()
  return vim.uv.fs_stat(self.filename) ~= nil
end

---@return string
function YaziPath:absolute()
  return vim.fn.fnamemodify(self.filename, ":p"):gsub("/$", "")
end

--- Make the path relative to the given base directory.
---@param base string|nil
---@return string
function YaziPath:make_relative(base)
  if not base then
    return self.filename
  end
  -- ensure base ends without slash for consistent prefix removal
  if base:sub(-1) == "/" then
    base = base:sub(1, -2)
  end
  local prefix = base .. "/"
  if self.filename:sub(1, #prefix) == prefix then
    return self.filename:sub(#prefix + 1)
  end
  return self.filename
end

function YaziPath:__tostring()
  return self.filename
end

return YaziPath
