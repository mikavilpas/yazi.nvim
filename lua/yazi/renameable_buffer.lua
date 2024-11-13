local plenary_path = require("plenary.path")
local plenary_iterators = require("plenary.iterators")

---@param path string
local function remove_trailing_slash(path)
  if path:sub(-1) == "/" then
    return path:sub(1, -2)
  end

  return path
end

---@class (exact) RenameableBuffer
---@field new fun(bufnr: number, path: string): RenameableBuffer
---@field __index RenameableBuffer
---@field bufnr number
---@field original_path string
---@field path Path
local RenameableBuffer = {}
RenameableBuffer.__index = RenameableBuffer

---@param bufnr number
---@param path string the original path of the buffer
function RenameableBuffer.new(bufnr, path)
  local self = setmetatable({}, RenameableBuffer)

  path = remove_trailing_slash(path)

  self.bufnr = bufnr
  self.original_path = path
  self.path = plenary_path:new(path)

  return self
end

---@param path string can be a parent directory or an exact file path
---@return boolean
function RenameableBuffer:matches_exactly(path)
  local path_a = vim.uv.fs_realpath(path) or path
  local path_b = vim.uv.fs_realpath(self.path.filename) or self.path.filename

  return path_a == path_b
end

---@param path string
---@return boolean
function RenameableBuffer:matches_parent(path)
  path = remove_trailing_slash(path)
  local found = plenary_iterators
    .iter(self.path:parents())
    :find(function(parent_path)
      return path == parent_path
    end)

  return found ~= nil
end

--- When hovering over a file or a directory `other`, return true if this
--- buffer is in the same directory as `other`.
---@param other string
---@return boolean
function RenameableBuffer:is_sibling_of_hovered(other)
  other = remove_trailing_slash(other)
  local utils = require("yazi.utils")

  local my_dir = utils.dir_of(self.path.filename)
  local other_dir = utils.dir_of(other)

  return my_dir.filename == other_dir.filename
end

---@param path string
---@return nil
function RenameableBuffer:rename(path)
  path = remove_trailing_slash(path)
  self.path = plenary_path:new(path)
end

---@param parent_from string the parent directory that was renamed
---@param parent_to string the new parent directory
---@return nil
function RenameableBuffer:rename_parent(parent_from, parent_to)
  local common = self.path.filename:sub(1, #parent_from)
  local rest = self.path.filename:sub(#common + 1, -1)

  local new_path = parent_to .. rest

  self.path = plenary_path:new(new_path)
end

return RenameableBuffer
