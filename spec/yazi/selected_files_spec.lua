local assert = require("luassert")
local utils = require("yazi.utils")
local reset = require("spec.yazi.helpers.reset")

describe("choosing the correct files when starting yazi", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  describe(" selected_file_path", function()
    it("when given a file, returns that file", function()
      vim.fn.bufadd("/my-tmp/file1")

      local result = utils.selected_file_path("/my-tmp/file1")

      assert.equal("/my-tmp/file1", result.filename)
    end)

    it("when no file is loaded, returns the current directory", function()
      local result = utils.selected_file_path()

      assert.equal(result.filename, vim.fn.getcwd())
    end)
  end)

  describe(" selected_files", function()
    it("when no file is loaded, returns the current directory", function()
      local result = utils.selected_file_paths()
      assert.equal(result[1].filename, vim.fn.getcwd())
    end)

    it("when given a file, returns that file", function()
      vim.fn.bufadd("/my-tmp/file1")

      local result = utils.selected_file_paths("/my-tmp/file1")

      assert.equal("/my-tmp/file1", result[1].filename)
      assert.equal(1, #result)
    end)

    it(
      "when there is another file open in a split, includes that file",
      function()
        vim.fn.bufadd("/my-tmp/file1")
        vim.cmd("vsplit /my-tmp/file2")

        local result = utils.selected_file_paths("/my-tmp/file1")

        assert.equal(#result, 2)

        assert.equal("/my-tmp/file1", result[1].filename)
        assert.equal("/my-tmp/file2", result[2].filename)
      end
    )
  end)
end)
