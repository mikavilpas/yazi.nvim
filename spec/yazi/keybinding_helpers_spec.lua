local assert = require("luassert")
local config_module = require("yazi.config")
local keybinding_helpers = require("yazi.keybinding_helpers")
local match = require("luassert.match")
local plenary_path = require("plenary.path")
local stub = require("luassert.stub")

describe("keybinding_helpers", function()
  local vim_cmd_stub
  local vim_fn_stub
  local vim_notify_stub
  local snapshot

  before_each(function()
    snapshot = assert:snapshot()
    vim_fn_stub = stub(vim.fn, "getcwd")
    vim_notify_stub = stub(vim, "notify")
    vim_cmd_stub = stub(vim, "cmd")
  end)

  after_each(function()
    snapshot:revert()
  end)

  describe("grep_in_directory", function()
    it("should grep in the parent directory for a file", function()
      local config = config_module.default()
      local s = stub(config.integrations, "grep_in_directory")

      keybinding_helpers.grep_in_directory(config, "/tmp/file")

      assert.stub(s).called_with("/tmp")
    end)

    it("should grep in the directory when a directory is passed", function()
      local config = config_module.default()
      local s = stub(config.integrations, "grep_in_directory")

      keybinding_helpers.grep_in_directory(config, "/tmp")

      assert.stub(s).called_with("/")
    end)

    it("should not crash if the integration is disabled", function()
      local config = config_module.default()
      config.integrations.grep_in_directory = nil

      keybinding_helpers.grep_in_directory(config, "/tmp/file")
    end)
  end)

  describe("grep_in_selected_files", function()
    it("should call `integrations.grep_in_selected_files`", function()
      local config = config_module.default()

      local results = {}
      config.integrations.grep_in_selected_files = function(paths)
        results = paths
      end

      keybinding_helpers.grep_in_selected_files(
        config,
        { "/tmp/file1", "/tmp/file2" }
      )

      assert.equal(2, #results)
      assert.are.same(
        { "/tmp/file1", "/tmp/file2" },
        vim
          .iter(results)
          :map(function(a)
            return a.filename
          end)
          :totable()
      )
    end)
  end)

  describe("replace_in_directory", function()
    it(
      "when a file is passed, should replace in the file's directory",
      function()
        local config = config_module.default()

        local stub_replace = stub(config.integrations, "replace_in_directory")

        keybinding_helpers.replace_in_directory(config, "/tmp/file")

        assert.stub(stub_replace).called_with(match.is_truthy())
        assert.equal("/tmp", stub_replace.calls[1].vals[1].filename)
      end
    )

    it(
      "when a directory is passed, should replace in the directory the directory is in",
      function()
        -- when hovering a directory and starting the replace operation, it
        -- should not replace in the directory itself. Otherwise starting the
        -- replace operation is too confusing
        local config = config_module.default()

        local stub_replace = stub(config.integrations, "replace_in_directory")

        keybinding_helpers.replace_in_directory(config, "/tmp")

        assert.stub(stub_replace).called_with(match.is_truthy())
        assert.equal("/", stub_replace.calls[1].vals[1].filename)
      end
    )
  end)

  describe("replace_in_selected_files", function()
    it("should call the integration if it's available", function()
      local config = config_module.default()

      ---@type Path[]
      local results = {}
      config.integrations.replace_in_selected_files = function(paths)
        results = paths
      end

      keybinding_helpers.replace_in_selected_files(
        config,
        { "/tmp/file1", "/tmp/file2" }
      )

      assert.equal(2, #results)

      local paths = vim
        .iter(results)
        :map(function(a)
          return a.filename
        end)
        :totable()
      assert.same({ "/tmp/file1", "/tmp/file2" }, paths)
    end)
  end)

  describe("change_working_directory", function()
    it(
      "should change the working directory when the cwd is available from ya",
      function()
        -- When yazi changes a directory, knowledge of that cwd becomes
        -- available to the plugin. This information is used to update the cwd
        -- in neovim

        ---@diagnostic disable-next-line: missing-fields
        keybinding_helpers.change_working_directory({
          ---@diagnostic disable-next-line: missing-fields
          ya_process = { cwd = "/tmp" },
        })

        assert.stub(vim_cmd_stub).called_with({ cmd = "cd", args = { "/tmp" } })

        assert.stub(vim_notify_stub).called_with('cwd changed to "/tmp"')
      end
    )

    it("uses yazi's input_path if no cwd is available yet", function()
      ---@diagnostic disable-next-line: missing-fields
      keybinding_helpers.change_working_directory({
        input_path = plenary_path:new("/tmp"),
        ---@diagnostic disable-next-line: missing-fields
        ya_process = {
          cwd = nil,
        },
      })

      assert.stub(vim_cmd_stub).called_with({ cmd = "cd", args = { "/tmp" } })
      assert.stub(vim_notify_stub).called_with('cwd changed to "/tmp"')
    end)

    it(
      "should not change the working directory if the new cwd is already the current one",
      function()
        vim_fn_stub.returns("/tmp")
        ---@diagnostic disable-next-line: missing-fields
        keybinding_helpers.change_working_directory({
          input_path = plenary_path:new("/tmp"),
          ---@diagnostic disable-next-line: missing-fields
          ya_process = {
            cwd = "/tmp",
          },
        })

        assert.stub(vim_fn_stub).called_with()
        assert.stub(vim_cmd_stub).called_at_most(0)
        assert.stub(vim_notify_stub).called_at_most(0)
      end
    )
  end)
end)
