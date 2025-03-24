---@module "plenary.path"

local assert = require("luassert")
local utils = require("yazi.utils")
local yazi = require("yazi")
local stub = require("luassert.stub")

local function create_file(path)
  local file = io.open(path, "w")
  assert(file, "could not open file")
  file:write("hello")
  file:close()
end

describe("relative_path", function()
  local snapshot
  local base_dir = os.tmpname() -- create a temporary file with a unique name

  before_each(function()
    snapshot = assert:snapshot()
    -- use the defaults, which set realpath and grealpath depending on the OS
    yazi.setup({})

    stub(vim.fn, "executable", function(command)
      if command == "realpath" or command == "grealpath" then
        return 1
      end
    end)

    assert(
      base_dir:match("/tmp/"),
      "base_dir is not under `/tmp/`, it's too dangerous to continue"
    )
    os.remove(base_dir)
    vim.fn.mkdir(base_dir, "p")
  end)

  after_each(function()
    vim.fn.delete(base_dir, "rf")
    snapshot:revert()
  end)

  -- test basic cases, not necessarily the entire feature set of GNU realpath

  it("returns the relative path from a directory to a subdirectory", function()
    local subdirectory = vim.fs.joinpath(base_dir, "subdirectory")

    vim.fn.mkdir(subdirectory)
    local result = utils.relative_path(yazi.config, base_dir, subdirectory)

    assert.are.same("subdirectory", result)
  end)

  it("returns the relative path from a directory to a subfile", function()
    local subfile = vim.fs.joinpath(base_dir, "subfile")
    create_file(subfile)

    local result = utils.relative_path(yazi.config, base_dir, subfile)

    assert.are.same("subfile", result)
  end)

  it("returns the relative path from a file to a directory", function()
    -- when yazi is started from a file (which is almost always), that file is
    -- called the "start file" here

    local file = vim.fs.joinpath(base_dir, "file")
    create_file(file)

    local subdirectory = vim.fs.joinpath(base_dir, "subdirectory")
    vim.fn.mkdir(subdirectory)

    local result = utils.relative_path(yazi.config, file, subdirectory)

    assert.are.same("subdirectory", result)
  end)
end)
