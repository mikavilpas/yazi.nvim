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
