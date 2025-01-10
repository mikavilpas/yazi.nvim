---@module "plenary.path"

local assert = require("luassert")
local mock = require("luassert.mock")
local match = require("luassert.match")
local spy = require("luassert.spy")
local test_files = require("spec.yazi.helpers.test_files")
package.loaded["yazi.process.yazi_process"] =
  require("spec.yazi.helpers.fake_yazi_process")
local fake_yazi_process = require("spec.yazi.helpers.fake_yazi_process")
local yazi_process = require("yazi.process.yazi_process")

local plugin = require("yazi")

describe("opening a file", function()
  after_each(function()
    package.loaded["yazi.process.yazi_process"] = yazi_process
  end)

  before_each(function()
    mock.revert(fake_yazi_process)
    package.loaded["yazi.process.yazi_process"] = mock(fake_yazi_process)
    plugin.setup({
      -- keymaps can only work with a real yazi process
      keymaps = false,
    })
  end)

  ---@param files string[]
  local function assert_opened_yazi_with_files(files)
    local call = mock(fake_yazi_process).start.calls[1]

    ---@type Path[]
    local actual_files = call.vals[3]
    assert.equal(type(actual_files), "table")

    local file_names = vim.tbl_map(function(file)
      return file.filename
    end, actual_files)

    for _, file in ipairs(files) do
      assert.is_true(type(file) == "string")
    end

    assert.is(files, file_names)
  end

  it("opens yazi with the current file selected", function()
    fake_yazi_process.setup_created_instances_to_instantly_exit({})

    -- the file name should have a space as well as special characters, in order to test that
    vim.api.nvim_command("edit " .. vim.fn.fnameescape("/abc/test file-$1.txt"))
    plugin.yazi({
      chosen_file_path = "/tmp/yazi_filechosen",
    })

    assert_opened_yazi_with_files({ "/abc/test file-$1.txt" })
  end)

  it("opens yazi with the current directory selected", function()
    fake_yazi_process.setup_created_instances_to_instantly_exit({})

    vim.api.nvim_command("edit /tmp/")

    plugin.yazi({
      chosen_file_path = "/tmp/yazi_filechosen",
    })

    assert_opened_yazi_with_files({ "/tmp/" })
  end)

  describe("when a file is selected in yazi's chooser", function()
    it(
      "calls the yazi_closed_successfully hook with the target_file and last_directory",
      function()
        fake_yazi_process.setup_created_instances_to_instantly_exit({
          ---@diagnostic disable-next-line: missing-fields
          last_cwd = { filename = "/abc" } --[[@as Path]],
        })

        ---@param state YaziClosedState
        ---@diagnostic disable-next-line: unused-local
        local spy_hook = spy.new(function(chosen_file, _config, state)
          assert.equal(nil, chosen_file)
          assert.equal("/abc", state.last_directory.filename)
        end)

        plugin.yazi({
          chosen_file_path = "/tmp/yazi_filechosen",
          ---@diagnostic disable-next-line: missing-fields
          hooks = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            yazi_closed_successfully = spy_hook,
          },
        })

        assert
          .spy(spy_hook)
          .called_with(nil, match.is_table(), match.is_table())
      end
    )

    it(
      "uses the parent directory of the input_path as the last_directory when no last_directory is available",
      function()
        local plenary_path = require("plenary.path")
        -- it can happen that we don't know what the last_directory was when
        -- yazi has exited. This currently happens when `ya` is started too
        -- late - yazi has already reported its `cd` event before `ya` starts
        -- due to https://github.com/sxyazi/yazi/issues/1314
        --
        -- we work around this by using the parent directory of the input_path
        -- since it's a good guess
        local target_file =
          "/tmp/test-file-potato-ea7142f8-ac6d-4037-882c-7dbc4f7b6c65.txt"
        test_files.create_test_file(target_file)

        fake_yazi_process.setup_created_instances_to_instantly_exit({
          selected_files = { target_file },
          events = {
            -- no events are emitted from yazi
          },
        })

        local spy_yazi_closed_successfully = spy.new(
          ---@param state YaziClosedState
          ---@diagnostic disable-next-line: unused-local
          function(chosen_file, _config, state)
            assert.equal(target_file, chosen_file)
            assert.equal("/tmp", state.last_directory.filename)
            assert.equal(
              "/tmp",
              plenary_path:new(target_file):parent().filename
            )
          end
        )

        plugin.yazi({
          chosen_file_path = "/tmp/yazi_filechosen",
          ---@diagnostic disable-next-line: missing-fields
          hooks = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            yazi_closed_successfully = spy_yazi_closed_successfully,
          },
        }, target_file)

        assert
          .spy(spy_yazi_closed_successfully)
          .called_with(target_file, match.is_table(), match.is_table())
      end
    )
  end)

  it("calls the yazi_opened hook when yazi is opened", function()
    local spy_yazi_opened_hook = spy.new(function() end)

    vim.api.nvim_command("edit /abc/yazi_opened_hook_file.txt")

    plugin.yazi({
      ---@diagnostic disable-next-line: missing-fields
      hooks = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        yazi_opened = spy_yazi_opened_hook,
      },
    })

    assert
      .spy(spy_yazi_opened_hook)
      .called_with("/abc/yazi_opened_hook_file.txt", match.is_number(), match.is_table())
  end)

  it("calls the open_file_function to open the selected file", function()
    local target_file = "/abc/test-file-lnotial.txt"
    fake_yazi_process.setup_created_instances_to_instantly_exit({
      selected_files = { target_file },
    })
    local spy_open_file_function = spy.new(function() end)

    vim.api.nvim_command("edit " .. target_file)

    plugin.yazi({
      chosen_file_path = "/tmp/yazi_filechosen",
      ---@diagnostic disable-next-line: assign-type-mismatch
      open_file_function = spy_open_file_function,
    })

    assert
      .spy(spy_open_file_function)
      .called_with(target_file, match.is_table(), match.is_table())
  end)
end)

describe("opening multiple files", function()
  local target_file_1 = "/abc/test-file-multiple-1.txt"
  local target_file_2 = "/abc/test-file-multiple-2.txt"

  it("can open multiple files", function()
    fake_yazi_process.setup_created_instances_to_instantly_exit({
      selected_files = { target_file_1, target_file_2 },
    })

    local spy_open_multiple_files = spy.new(function() end)
    plugin.yazi({
      ---@diagnostic disable-next-line: missing-fields
      hooks = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        yazi_opened_multiple_files = spy_open_multiple_files,
      },
      chosen_file_path = "/tmp/yazi_filechosen-123",
    })

    assert.spy(spy_open_multiple_files).called_with({
      target_file_1,
      target_file_2,
    }, match.is_table(), match.is_table())
  end)
end)
