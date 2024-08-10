local RenameableBuffer = require("yazi.renameable_buffer")
local assert = require("luassert")

describe("the RenameableBuffer class", function()
  it("matches a parent directory", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    local result = rename:matches_parent("/my-tmp/")
    assert.is_true(result)
  end)

  it("matches a parent directory with a trailing slash", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    local result = rename:matches_parent("/my-tmp")
    assert.is_true(result)
  end)

  it("matches an exact file path", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    local result = rename:matches_exactly("/my-tmp/file1")
    assert.is_true(result)
  end)

  it("does not match a different parent directory", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    assert.is_false(rename:matches_exactly("/my-tmp2"))
  end)

  it("does not match a different file path", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    assert.is_false(rename:matches_exactly("/my-tmp/file2"))
  end)

  ---@param suffix string
  local function create_temp_file(suffix)
    local file_path = vim.fn.tempname() .. suffix
    local file, err = io.open(file_path, "w")
    assert(file ~= nil, "Failed to create a temporary file " .. file_path)
    assert(
      err == nil,
      "Failed to create a temporary file " .. file_path .. ": " .. (err or "")
    )
    local _, write_err = file:write("hello")
    assert(
      write_err == nil,
      "Failed to write to a temporary file " .. file_path
    )
    file:close()

    return file_path
  end

  it("matches when the file is a symlink", function()
    local file1_path = create_temp_file("_file1")
    local file2_path = vim.fn.tempname() .. "_file2"

    local success, a, b = vim.uv.fs_symlink(file1_path, file2_path)
    assert(success, vim.inspect({ "Failed to create a symlink", a, b }))

    local rename = RenameableBuffer.new(1, file1_path)
    assert.is_true(rename:matches_exactly(file2_path))
  end)

  it("renames a file", function()
    local rename = RenameableBuffer.new(1, "/my-tmp/file1")
    rename:rename("/my-tmp/file2")
    assert.are.equal("/my-tmp/file2", rename.path.filename)

    -- does not change the original path
    assert.are.equal("/my-tmp/file1", rename.original_path)
  end)

  it("renames the buffer's parent directory", function()
    local buffer = RenameableBuffer.new(1, "/my-tmp/file1")
    buffer:rename_parent("/my-tmp", "/my-tmp2")
    assert.are.equal("/my-tmp2/file1", buffer.path.filename)

    -- does not change the original path
    assert.are.equal("/my-tmp/file1", buffer.original_path)
  end)

  describe("is_sibling_of_hovered", function()
    local base_dir

    before_each(function()
      base_dir = os.tmpname()
      -- refuse to remove anything outside of /tmp/
      assert(base_dir:match("/tmp/"), "Failed to create a temporary directory")

      os.remove(base_dir)
      vim.fn.mkdir(base_dir, "p")
    end)

    it("returns true for files in the same directory (happy path)", function()
      local parent_directory = vim.fs.joinpath(base_dir, "parent_directory")
      vim.fn.mkdir(parent_directory)

      local buffer =
        RenameableBuffer.new(1, vim.fs.joinpath(parent_directory, "file1"))
      assert.is_true(
        buffer:is_sibling_of_hovered(vim.fs.joinpath(parent_directory, "file2"))
      )
    end)

    it("returns false for files in different directories", function()
      local dir1 = vim.fs.joinpath(base_dir, "dir1")
      vim.fn.mkdir(dir1)

      local dir2 = vim.fs.joinpath(base_dir, "dir2")
      vim.fn.mkdir(dir2)

      local buffer = RenameableBuffer.new(1, vim.fs.joinpath(dir1, "file1"))
      assert.is_false(
        buffer:is_sibling_of_hovered(vim.fs.joinpath(dir2, "file2"))
      )
    end)

    it("can recognize the siblings of hovered directories", function()
      -- when yazi hovers the helpers/ directory, it should highlight buffers
      -- in this directory (`.`), not buffers in helpers/
      --
      --   󰉋 helpers
      --    file.lua
      --

      local this_dir = vim.fs.joinpath(base_dir, "this_directory")
      local helpers_dir = vim.fs.joinpath(this_dir, "helpers")

      vim.fn.mkdir(this_dir, "p")
      vim.fn.mkdir(helpers_dir, "p")

      local file_path = vim.fs.joinpath(this_dir, "file.lua")

      local buffer = RenameableBuffer.new(1, file_path)
      assert.is_true(buffer:is_sibling_of_hovered(helpers_dir))
    end)
  end)
end)
