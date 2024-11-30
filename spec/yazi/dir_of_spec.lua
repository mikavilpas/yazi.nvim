local assert = require("luassert")
local utils = require("yazi.utils")

describe("dir_of helper function", function()
  describe(
    "when files and directories don't exist on disk (only in Neovim)",
    function()
      it("can detect the dir of a file", function()
        local d = utils.dir_of("/my-tmp/file1")
        assert.equal("/my-tmp", d.filename)
      end)

      it("can detect the dir of a directory", function()
        -- I think it just thinks directories are files because it cannot know
        -- better. But this is still a good default.
        local d = utils.dir_of("/my-tmp/dir1")
        assert.equal("/my-tmp", d.filename)
      end)
    end
  )

  describe("when files and directories exist on disk", function()
    local base_dir = os.tmpname() -- create a temporary file with a unique name

    before_each(function()
      assert(
        base_dir:match("/tmp/"),
        "base_dir is not under `/tmp/`, it's too dangerous to continue"
      )
      os.remove(base_dir)
      vim.fn.mkdir(base_dir, "p")
    end)

    after_each(function()
      vim.fn.delete(base_dir, "rf")
    end)

    it("can get the directory of a file", function()
      local file = vim.fs.joinpath(base_dir, "abc.txt")
      local d = utils.dir_of(file)
      assert.equal(base_dir, d.filename)
    end)

    it("can get the directory of a directory", function()
      local dir = vim.fs.joinpath(base_dir, "dir1")
      vim.fn.mkdir(dir)
      local d = utils.dir_of(dir)

      assert.equal(base_dir, d.filename)
    end)
  end)
end)
