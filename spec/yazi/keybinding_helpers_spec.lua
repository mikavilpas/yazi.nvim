local assert = require("luassert")
local config_module = require("yazi.config")
local keybinding_helpers = require("yazi.keybinding_helpers")
local match = require("luassert.match")
local stub = require("luassert.stub")

describe("keybinding_helpers", function()
  describe("grep_in_directory", function()
    it("should grep in the parent directory for a file", function()
      local config = config_module.default()
      local s = stub(config.integrations, "grep_in_directory")

      keybinding_helpers.grep_in_directory(config, "/tmp/file")

      assert.stub(s).was_called_with("/tmp")
    end)

    it("should grep in the directory when a directory is passed", function()
      local config = config_module.default()
      local s = stub(config.integrations, "grep_in_directory")

      keybinding_helpers.grep_in_directory(config, "/tmp")

      assert.stub(s).was_called_with("/")
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

      assert.equals(2, #results)
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

        assert.stub(stub_replace).was_called_with(match.is_truthy())
        assert.equals("/tmp", stub_replace.calls[1].vals[1].filename)
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

        assert.stub(stub_replace).was_called_with(match.is_truthy())
        assert.equals("/", stub_replace.calls[1].vals[1].filename)
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

      assert.equals(2, #results)

      local paths = vim
        .iter(results)
        :map(function(a)
          return a.filename
        end)
        :totable()
      assert.same({ "/tmp/file1", "/tmp/file2" }, paths)
    end)
  end)
end)
