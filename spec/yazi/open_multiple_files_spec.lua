local reset = require("spec.yazi.helpers.reset")

describe("the default configuration", function()
  before_each(function()
    reset.clear_all_buffers()
  end)

  local plenary_path = require("plenary.path")
  local test_file_path = plenary_path:new(vim.fn.getcwd(), "test-file.txt")

  it("opens multiple files in buffers by default", function()
    local config = require("yazi.config").default()
    local chosen_files = { "/abc/test-file.txt", "/abc/test-file2.txt" }

    config.hooks.yazi_opened_multiple_files(
      chosen_files,
      config,
      test_file_path
    )

    local buffers = vim.api.nvim_list_bufs()

    assert.equals(2, #buffers)
    assert.equals("/abc/test-file.txt", vim.api.nvim_buf_get_name(buffers[1]))
    assert.equals("/abc/test-file2.txt", vim.api.nvim_buf_get_name(buffers[2]))
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
      test_file_path
    )

    local quickfix_list = vim.fn.getqflist()

    assert.equals(2, #quickfix_list)
    assert.equals("/abc/test-$@file.txt", quickfix_list[1].text)
    assert.equals("/abc/test-file2.txt", quickfix_list[2].text)
  end)
end)
