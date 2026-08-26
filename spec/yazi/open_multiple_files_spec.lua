local reset = require("spec.yazi.helpers.reset")
local assert = require("luassert")

describe("the default configuration", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  local plenary_path = require("plenary.path")
  local last_directory = plenary_path:new(vim.fn.getcwd())

  it("opens multiple files in buffers by default", function()
    local config = require("yazi.config").default()
    local chosen_files = { "/abc/test-file.txt", "/abc/test-file2.txt" }

    config.hooks.yazi_opened_multiple_files(
      chosen_files,
      config,
      { last_directory = last_directory }
    )

    local buffers = vim.api.nvim_list_bufs()

    assert.equal(2, #buffers)
    assert.equal("/abc/test-file.txt", vim.api.nvim_buf_get_name(buffers[1]))
    assert.equal("/abc/test-file2.txt", vim.api.nvim_buf_get_name(buffers[2]))
  end)

  it("can display multiple files in the quickfix list", function()
    local config = require("yazi.config").default()
    config.hooks.yazi_opened_multiple_files =
      require("yazi.openers").send_files_to_quickfix_list

    -- include problematic characters in the file names to preserve their behaviour
    local chosen_files = { "/abc/test-$@file.txt", "/abc/test-file2.txt" }

    config.hooks.yazi_opened_multiple_files(
      chosen_files,
      config,
      { last_directory = last_directory }
    )

    local quickfix_list = vim.fn.getqflist()

    assert.equal(2, #quickfix_list)
    assert.equal("/abc/test-$@file.txt", quickfix_list[1].text)
    assert.equal("/abc/test-file2.txt", quickfix_list[2].text)
  end)
end)

describe("open_multiple_files", function()
  local base_dir = os.tmpname()

  before_each(function()
    reset.clear_all_buffers()

    -- refuse to remove anything outside of /tmp/
    assert(base_dir:match("/tmp/"), "Failed to create a temporary directory")
    os.remove(base_dir)
    vim.fn.mkdir(base_dir, "p")

    -- on macos /tmp is a symlink to /private/tmp, and neovim resolves buffer
    -- names to the real path
    base_dir = vim.fn.resolve(base_dir)
  end)

  it("leaves directories out of the arglist", function()
    local file = base_dir .. "/test-file.txt"
    vim.fn.writefile({ "hello" }, file)

    require("yazi.openers").open_multiple_files({ base_dir, file })

    local buffers = vim.api.nvim_list_bufs()
    assert.equal(1, #buffers)
    assert.equal(file, vim.api.nvim_buf_get_name(buffers[1]))
  end)

  it("does not touch the arglist when only directories were given", function()
    require("yazi.openers").open_multiple_files({ base_dir })

    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      assert.is_not.equal(base_dir, vim.api.nvim_buf_get_name(buffer))
    end
  end)
end)
