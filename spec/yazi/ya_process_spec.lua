local assert = require("luassert")
local ya_process = require("yazi.process.ya_process")
local spy = require("luassert.spy")

require("plenary.async").tests.add_to_env()

describe("the get_yazi_command() function", function()
  it("specifies opening multiple tabs when enabled in the config", function()
    local config = require("yazi.config").default()
    config.open_multiple_tabs = true
    config.chosen_file_path = "/tmp/chosen_file_path"

    local ya = ya_process.new(config, "yazi_id_123")

    local paths = {
      { filename = "file1" },
      { filename = "file2" },
    }

    local command = ya:get_yazi_command(paths)

    assert.are.same(
      "yazi 'file1' 'file2' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123",
      command
    )
  end)

  it(
    "does not specify opening multiple tabs when disabled in the config",
    function()
      local config = require("yazi.config").default()
      config.open_multiple_tabs = false
      config.chosen_file_path = "/tmp/chosen_file_path"

      local ya = ya_process.new(config, "yazi_id_123")

      local paths = {
        { filename = "file1" },
        { filename = "file2" },
      }

      local command = ya:get_yazi_command(paths)

      assert.are.same(
        "yazi 'file1' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123",
        command
      )
    end
  )

  it("doesn't open duplicate tabs", function()
    local config = require("yazi.config").default()
    config.open_multiple_tabs = true
    config.chosen_file_path = "/tmp/chosen_file_path"

    local ya = ya_process.new(config, "yazi_id_123")

    local paths = {
      { filename = "file1" },
      { filename = "file1" },

      { filename = "file2" },
      { filename = "file2" },

      { filename = "file3" },
    }

    local command = ya:get_yazi_command(paths)

    assert.are.same(
      "yazi 'file1' 'file2' 'file3' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123",
      command
    )
  end)
end)

describe("process_events()", function()
  describe("cd events", function()
    -- processing cd events is important so that keymaps can retrieve the cwd
    -- and operate on it

    local config = require("yazi.config").default()

    it("stores the current working directory (cwd)", function()
      local ya = ya_process.new(config, "yazi_id_123")

      ya:process_events({
        {
          type = "cd",
          timestamp = "2021-09-01T12:00:00Z",
          id = "cd_123",
          url = "/tmp",
        } --[[@as YaziChangeDirectoryEvent]],
      })

      assert.are.same("/tmp", ya.cwd)
    end)

    it("overrides the previous cwd when it's changed multiple times", function()
      local ya = ya_process.new(config, "yazi_id_123")
      ya:process_events({
        {
          type = "cd",
          timestamp = "2021-09-01T12:00:00Z",
          id = "cd_123",
          url = "/tmp",
        } --[[@as YaziChangeDirectoryEvent]],
        {
          type = "cd",
          timestamp = "2021-09-01T12:00:00Z",
          id = "cd_123",
          url = "/tmp/directory",
        } --[[@as YaziChangeDirectoryEvent]],
      })

      assert.are.same("/tmp/directory", ya.cwd)
    end)
  end)

  describe("YaziRenamedOrMoved events", function()
    before_each(function()
      -- delete the autocmd to prevent it from being called multiple times
      vim.api.nvim_command("silent! autocmd! YaziRenamedOrMoved")
    end)

    it(
      "gets published when YaziRenameEvent events are received from yazi",
      function()
        local config = require("yazi.config").default()
        local ya = ya_process.new(config, "yazi_id_123")

        ---@type YaziRenameEvent[]
        local events = {
          {
            type = "rename",
            timestamp = "2021-09-01T12:00:00Z",
            id = "rename_123",
            data = {
              from = "/tmp/old_path",
              to = "/tmp/new_path",
            },
          },
        }

        local event_callback = spy.new()
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events)
        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).was_called()
        assert.same(#event_callback.calls, 1)

        local event = event_callback.calls[1].vals[1]
        assert.same({
          changes = {
            ["/tmp/old_path"] = "/tmp/new_path",
          },
        }, event.data)
      end
    )

    it(
      "gets published when YaziMoveEvent events are received from yazi",
      function()
        local config = require("yazi.config").default()
        local ya = ya_process.new(config, "yazi_id_123")

        ---@type YaziMoveEvent[]
        local events = {
          {
            type = "move",
            timestamp = "2021-09-01T12:00:00Z",
            id = "rename_123",
            data = {
              from = "/tmp/old_path",
              to = "/tmp/new_path",
            },
          },
        }

        local event_callback = spy.new()
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events)
        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).was_called()
        assert.same(#event_callback.calls, 1)

        local event = event_callback.calls[1].vals[1]
        assert.same({
          changes = {
            ["/tmp/old_path"] = "/tmp/new_path",
          },
        }, event.data)
      end
    )

    it(
      "gets published when YaziBulkEvent events are received from yazi",
      function()
        local config = require("yazi.config").default()
        local ya = ya_process.new(config, "yazi_id_123")

        ---@type YaziBulkEvent[]
        local events = {
          {
            type = "bulk",
            changes = {
              ["/tmp/old_path1"] = "/tmp/new_path1",
              ["/tmp/old_path2"] = "/tmp/new_path2",
            },
          },
        }

        local event_callback = spy.new()
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events)
        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).was_called()
        assert.same(#event_callback.calls, 1)

        local event = event_callback.calls[1].vals[1]
        assert.same({
          changes = {
            ["/tmp/old_path1"] = "/tmp/new_path1",
            ["/tmp/old_path2"] = "/tmp/new_path2",
          },
        }, event.data)
      end
    )
  end)
end)

describe("opening the yazi in a terminal", function()
  local config = require("yazi.config").default()
  local path = require("plenary.path"):new()

  local snapshot

  before_each(function()
    snapshot = assert.snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  it(
    "sets the NVIM_CWD environment variable to the current working directory",
    function()
      -- selene: allow(incorrect_standard_library_use)
      os.remove = spy.new()
      vim.uv.cwd = spy.new(function()
        return "/tmp/fakedir"
      end)
      local termopen_spy = spy.new()
      vim.fn.termopen = termopen_spy

      require("yazi.process.yazi_process"):start(
        config,
        { path },
        function() end
      )

      assert(termopen_spy.calls[1])
      assert(termopen_spy.calls[1].vals[2])
      assert(termopen_spy.calls[1].vals[2].env)
      local env = termopen_spy.calls[1].vals[2].env

      assert.equals(env.NVIM_CWD, "/tmp/fakedir")
    end
  )
end)
