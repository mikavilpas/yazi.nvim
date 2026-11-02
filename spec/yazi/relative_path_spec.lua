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
  local base_dir

  before_each(function()
    snapshot = assert:snapshot()
    yazi.setup({})

    -- Copying paths must work without coreutils or spawning a subprocess.
    stub(vim.fn, "executable", function()
      return 0
    end)
    stub(vim, "system", function()
      error("The built-in resolver must not spawn a subprocess")
    end)

    base_dir = vim.fn.tempname()
    vim.fn.mkdir(base_dir, "p")
  end)

  after_each(function()
    vim.fn.delete(base_dir, "rf")
    snapshot:revert()
  end)

  -- Exercise the default resolver, not an explicitly configured application.
  local realpath_application =
    yazi.config.integrations.resolve_relative_path_application
  assert(realpath_application)

  it("returns the relative path from a directory to a subdirectory", function()
    local subdirectory = vim.fs.joinpath(base_dir, "subdirectory")

    vim.fn.mkdir(subdirectory)
    local result = utils.relative_path(realpath_application, {
      source_dir = base_dir,
      selected_file = subdirectory,
    })

    assert.are.same("subdirectory", result)
  end)

  it("returns the relative path from a directory to a subfile", function()
    local subfile = vim.fs.joinpath(base_dir, "subfile")
    create_file(subfile)

    local result = utils.relative_path(realpath_application, {
      source_dir = base_dir,
      selected_file = subfile,
    })

    assert.are.same("subfile", result)
  end)

  it("returns the relative path from a file to a directory", function()
    -- when yazi is started from a file (which is almost always), that file is
    -- called the "start file" here

    local file = vim.fs.joinpath(base_dir, "file")
    create_file(file)

    local subdirectory = vim.fs.joinpath(base_dir, "subdirectory")
    vim.fn.mkdir(subdirectory)

    local result = utils.relative_path(realpath_application, {
      source_dir = file,
      selected_file = subdirectory,
    })

    assert.are.same("subdirectory", result)
  end)

  it(
    "handles siblings, parents, identical paths, and component boundaries",
    function()
      local source = vim.fs.joinpath(base_dir, "src", "nested")
      local target = vim.fs.joinpath(base_dir, "src-other")
      vim.fn.mkdir(source, "p")
      vim.fn.mkdir(target)

      for _, case in ipairs({
        { target, "../../src-other" },
        { base_dir, "../.." },
        { source, "." },
      }) do
        assert.are.same(
          case[2],
          utils.relative_path(realpath_application, {
            source_dir = source,
            selected_file = case[1],
          })
        )
      end
    end
  )

  it(
    "preserves special characters without expanding environment variables",
    function()
      local name = "a space 中文\n$HOME"
      local target = vim.fs.joinpath(base_dir, name)
      create_file(target)

      assert.are.same(
        name,
        utils.relative_path(realpath_application, {
          source_dir = base_dir,
          selected_file = target,
        })
      )
    end
  )

  it("resolves symbolic links before computing the relative path", function()
    local real = vim.fs.joinpath(base_dir, "real")
    local link = vim.fs.joinpath(base_dir, "link")
    vim.fn.mkdir(vim.fs.joinpath(real, "nested"), "p")
    assert(vim.uv.fs_symlink(real, link, { dir = true }))
    create_file(vim.fs.joinpath(real, "file"))

    assert.are.same(
      "../file",
      utils.relative_path(realpath_application, {
        source_dir = vim.fs.joinpath(link, "nested"),
        selected_file = vim.fs.joinpath(real, "file"),
      })
    )
    assert.are.same(
      "real/file",
      utils.relative_path(realpath_application, {
        source_dir = base_dir,
        selected_file = vim.fs.joinpath(link, "file"),
      })
    )
  end)

  it("rejects dangling symbolic links", function()
    local link = vim.fs.joinpath(base_dir, "link")
    assert(vim.uv.fs_symlink(vim.fs.joinpath(base_dir, "missing"), link))

    assert.error_matches(function()
      utils.relative_path(realpath_application, {
        source_dir = base_dir,
        selected_file = link,
      })
    end, "ENOENT")
  end)

  it("allows a missing leaf but rejects a missing parent directory", function()
    assert.are.same(
      "missing",
      utils.relative_path(realpath_application, {
        source_dir = base_dir,
        selected_file = vim.fs.joinpath(base_dir, "missing"),
      })
    )
    assert.error_matches(function()
      utils.relative_path(realpath_application, {
        source_dir = base_dir,
        selected_file = vim.fs.joinpath(base_dir, "missing", "file"),
      })
    end, "ENOENT")
  end)
end)

describe("an explicitly configured external resolver", function()
  it("still invokes the configured application", function()
    local snapshot = assert:snapshot()
    stub(vim.fn, "executable", function()
      return 1
    end)
    local command
    stub(vim, "system", function(args)
      command = args
      return {
        wait = function()
          return { code = 0, stdout = "external-result\n" }
        end,
      }
    end)

    local result = utils.relative_path("custom-realpath", {
      source_dir = vim.uv.cwd(),
      selected_file = "selected-file",
    })
    snapshot:revert()

    assert.are.same("external-result", result)
    assert.are.same({
      "custom-realpath",
      "--relative-to",
      vim.uv.cwd(),
      "selected-file",
    }, command)
  end)
end)

describe("resolve_relative_path_implementation in the config", function()
  local snapshot

  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  it("can fallback to the default_implementation", function()
    local get_relative_path =
      require("yazi.integrations.get_relative_path").get_relative_path
    local config = require("yazi.config").default()

    -- stub the default implementation
    local default_implementation_stub = stub(utils, "relative_path", function()
      return "default_relative_path"
    end)

    -- the user adds an implementation that falls back to the default
    -- implementation
    config.integrations.resolve_relative_path_implementation = function(
      chosen_file,
      default_implementation
    )
      return default_implementation(chosen_file)
    end

    -- call the implementation
    local result = get_relative_path(config, "path/to/target")

    assert
      .stub(default_implementation_stub)
      .was_called_with(config.integrations.resolve_relative_path_application, "path/to/target")
    assert.are.same("default_relative_path", result)
  end)
end)
