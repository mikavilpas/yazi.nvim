local openers = require("yazi.openers")
local stub = require("luassert.stub")
local assert = require("luassert")

local base_dir = os.tmpname() -- create a temporary file with a unique name
local snapshot

before_each(function()
  snapshot = assert:snapshot()
  stub(vim, "cmd")

  -- refuse to remove anything outside of /tmp/
  assert(base_dir:match("/tmp/"), "Failed to create a temporary directory")
  os.remove(base_dir)
  vim.fn.mkdir(base_dir, "p")
end)

after_each(function()
  snapshot:revert()
end)

describe("open_file", function()
  it("does not raise if neovim reports a swap-file attention", function()
    vim.cmd.invokes(function()
      error("nvim_exec2(), line 1: Vim(edit):E325: ATTENTION")
    end)

    assert.has_no.errors(function()
      openers.open_file("/tmp/file.txt")
    end)
  end)

  it("raises non-swap-file errors", function()
    vim.cmd.invokes(function()
      error("Vim(edit):E37: No write since last change")
    end)

    assert.error_matches(function()
      openers.open_file("/tmp/file.txt")
    end, "E37:", 1, true)
  end)
end)

describe("open_file_in_vertical_split", function()
  it("does not open if the given path is a directory", function()
    -- a directory cannot be opened in a split - it would show the netrw file
    -- explorer, which is less useful than yazi
    openers.open_file_in_vertical_split(base_dir)

    assert.stub(vim.cmd).called_at_most(0)
  end)
end)

describe("open_file_in_horizontal_split", function()
  it("does not open if the given path is a directory", function()
    -- a directory cannot be opened in a split - it would show the netrw file
    -- explorer, which is less useful than yazi
    openers.open_file_in_horizontal_split(base_dir)

    assert.stub(vim.cmd).called_at_most(0)
  end)
end)

describe("open_file_in_tab", function()
  it("does not open if the given path is a directory", function()
    -- a directory cannot be opened in a tab - it would show the netrw file
    -- explorer, which is less useful than yazi
    openers.open_file_in_tab(base_dir)

    assert.stub(vim.cmd).called_at_most(0)
  end)
end)
