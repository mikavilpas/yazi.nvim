local RenameableBuffer = require('yazi.renameable_buffer')
local assert = require('luassert')

describe('the RenameableBuffer class', function()
  it('matches a parent directory', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    local result = rename:matches_parent('/my-tmp/')
    assert.is_true(result)
  end)

  it('matches a parent directory with a trailing slash', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    local result = rename:matches_parent('/my-tmp')
    assert.is_true(result)
  end)

  it('matches an exact file path', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    local result = rename:matches_exactly('/my-tmp/file1')
    assert.is_true(result)
  end)

  it('does not match a different parent directory', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    assert.is_false(rename:matches_exactly('/my-tmp2'))
  end)

  it('does not match a different file path', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    assert.is_false(rename:matches_exactly('/my-tmp/file2'))
  end)

  ---@param suffix string
  local function create_temp_file(suffix)
    local file_path = vim.fn.tempname() .. suffix
    local file, err = io.open(file_path, 'w')
    assert(file ~= nil, 'Failed to create a temporary file ' .. file_path)
    assert(
      err == nil,
      'Failed to create a temporary file ' .. file_path .. ': ' .. (err or '')
    )
    local _, write_err = file:write('hello')
    assert(
      write_err == nil,
      'Failed to write to a temporary file ' .. file_path
    )
    file:close()

    return file_path
  end

  it('matches when the file is a symlink', function()
    local file1_path = create_temp_file('_file1')
    local file2_path = vim.fn.tempname() .. '_file2'

    local success, a, b = vim.uv.fs_symlink(file1_path, file2_path)
    assert(success, vim.inspect({ 'Failed to create a symlink', a, b }))

    local rename = RenameableBuffer.new(1, file1_path)
    assert.is_true(rename:matches_exactly(file2_path))
  end)

  it('renames a file', function()
    local rename = RenameableBuffer.new(1, '/my-tmp/file1')
    rename:rename('/my-tmp/file2')
    assert.are.equal('/my-tmp/file2', rename.path.filename)

    -- does not change the original path
    assert.are.equal('/my-tmp/file1', rename.original_path)
  end)

  it("renames the buffer's parent directory", function()
    local buffer = RenameableBuffer.new(1, '/my-tmp/file1')
    buffer:rename_parent('/my-tmp', '/my-tmp2')
    assert.are.equal('/my-tmp2/file1', buffer.path.filename)

    -- does not change the original path
    assert.are.equal('/my-tmp/file1', buffer.original_path)
  end)
end)
