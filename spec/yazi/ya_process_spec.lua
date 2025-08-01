local assert = require("luassert")
local ya_process = require("yazi.process.ya_process")
local spy = require("luassert.spy")

local yazi_id = "yazi_id_123"

describe("the get_yazi_command() function", function()
  it("specifies opening multiple tabs when enabled in the config", function()
    local config = require("yazi.config").default()
    config.open_multiple_tabs = true
    config.chosen_file_path = "/tmp/chosen_file_path"
    config.cwd_file_path = "/tmp/cwd_file_path"
    config.future_features.new_shell_escaping = false

    local ya = ya_process.new(config, yazi_id)

    local paths = {
      { filename = "file1" },
      { filename = "file2" },
    }

    local command = ya:get_yazi_command(paths)

    assert.are.same(
      "yazi 'file1' 'file2' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
      command
    )
  end)

  it(
    "does not specify opening multiple tabs when disabled in the config",
    function()
      local config = require("yazi.config").default()
      config.open_multiple_tabs = false
      config.chosen_file_path = "/tmp/chosen_file_path"
      config.cwd_file_path = "/tmp/cwd_file_path"
      config.future_features.new_shell_escaping = false

      local ya = ya_process.new(config, yazi_id)

      local paths = {
        { filename = "file1" },
        { filename = "file2" },
      }

      local command = ya:get_yazi_command(paths)

      assert.are.same(
        "yazi 'file1' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
        command
      )
    end
  )

  it("doesn't open duplicate tabs", function()
    local config = require("yazi.config").default()
    config.open_multiple_tabs = true
    config.chosen_file_path = "/tmp/chosen_file_path"
    config.cwd_file_path = "/tmp/cwd_file_path"
    config.future_features.new_shell_escaping = false

    local ya = ya_process.new(config, yazi_id)

    local paths = {
      { filename = "file1" },
      { filename = "file1" },

      { filename = "file2" },
      { filename = "file2" },

      { filename = "file3" },
    }

    local command = ya:get_yazi_command(paths)

    assert.are.same(
      "yazi 'file1' 'file2' 'file3' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
      command
    )
  end)

  it("returns a table if new_shell_escaping is used", function()
    -- Doing this lets vim.fn.jobstart() handle the escaping for shell
    -- arguments, which might work more reliably across different systems.
    -- https://github.com/mikavilpas/yazi.nvim/issues/1101
    local config = require("yazi.config").default()
    config.open_multiple_tabs = true
    config.chosen_file_path = "/tmp/chosen_file_path"
    config.cwd_file_path = "/tmp/cwd_file_path"
    assert(config.future_features.new_shell_escaping)

    local ya = ya_process.new(config, yazi_id)

    local paths = { { filename = "file1" } }
    local command = ya:get_yazi_command(paths)

    assert(type(command) == "table")

    assert.are_equal(
      "yazi file1 --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
      table.concat(command, " ")
    )
  end)

  describe("escape_path_implementation", function()
    it("can handle paths with spaces", function()
      local config = require("yazi.config").default()
      config.chosen_file_path = "/tmp/chosen_file_path"
      config.cwd_file_path = "/tmp/cwd_file_path"
      config.future_features.new_shell_escaping = false

      local ya = ya_process.new(config, yazi_id)

      local command = ya:get_yazi_command({ { filename = "file 1" } })

      assert.are.same(
        "yazi 'file 1' --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
        command
      )
    end)

    it("allows customizing the way shellescape is done", function()
      local config = require("yazi.config").default()
      config.chosen_file_path = "/tmp/chosen_file_path"
      config.cwd_file_path = "/tmp/cwd_file_path"
      config.future_features.new_shell_escaping = false

      config.integrations.escape_path_implementation = function(path)
        -- replace / with \
        local result = path:gsub("/", "\\")
        return result
      end

      local ya = ya_process.new(config, yazi_id)

      local command = ya:get_yazi_command({ { filename = "file/1" } })

      assert.are.same(
        "yazi file\\1 --chooser-file /tmp/chosen_file_path --client-id yazi_id_123 --cwd-file /tmp/cwd_file_path",
        command
      )
    end)
  end)
end)

describe("process_events()", function()
  describe("cd events", function()
    -- processing cd events is important so that keymaps can retrieve the cwd
    -- and operate on it

    local config = require("yazi.config").default()

    it("stores the current working directory (cwd)", function()
      local ya = ya_process.new(config, yazi_id)

      ya:process_events({
        {
          type = "cd",
          yazi_id = yazi_id,
          url = "/tmp",
        } --[[@as YaziChangeDirectoryEvent]],
      }, {}, {})

      assert.are.same("/tmp", ya.cwd)
    end)

    it("ignores cd events from yazis with a different yazi_id", function()
      local ya = ya_process.new(config, yazi_id)

      ya:process_events({
        {
          type = "cd",
          yazi_id = "cd_123", -- different yazi_id
          url = "/tmp",
        } --[[@as YaziChangeDirectoryEvent]],
      }, {}, {})

      assert.are.same(nil, ya.cwd)
    end)

    it("overrides the previous cwd when it's changed multiple times", function()
      local ya = ya_process.new(config, yazi_id)
      ya:process_events({
        {
          type = "cd",
          yazi_id = yazi_id,
          url = "/tmp",
        } --[[@as YaziChangeDirectoryEvent]],
        {
          type = "cd",
          yazi_id = yazi_id,
          url = "/tmp/directory",
        } --[[@as YaziChangeDirectoryEvent]],
      }, {}, {} --[[@as YaziActiveContext]])

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
        local ya = ya_process.new(config, yazi_id)

        ---@type YaziRenameEvent[]
        local events = {
          {
            type = "rename",
            yazi_id = "rename_123",
            data = {
              from = "/tmp/old_path",
              to = "/tmp/new_path",
            },
          },
        }

        local event_callback = spy.new(function() end)
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events, {})
        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).called(1)

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
        local ya = ya_process.new(config, yazi_id)

        ---@type YaziMoveEvent[]
        local events = {
          {
            type = "move",
            yazi_id = "rename_123",
            data = {
              items = {
                {
                  from = "/tmp/old_path",
                  to = "/tmp/new_path",
                },
              },
            },
          },
        }

        local event_callback = spy.new(function() end)
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events, {})

        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).called(1)

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
        local ya = ya_process.new(
          config,
          yazi_id,
          function() end,
          "/tmp/new_path1"
        )

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

        local event_callback = spy.new(function() end)
        vim.api.nvim_create_autocmd("User", {
          pattern = "YaziRenamedOrMoved",
          callback = function(...)
            event_callback(...)
          end,
        })

        ya:process_events(events, {})
        vim.wait(2000, function()
          return #event_callback.calls > 0
        end)

        assert.spy(event_callback).called(1)

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

describe("opening yazi in a terminal", function()
  local config = require("yazi.config").default()
  local path = require("plenary.path"):new()

  local snapshot

  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  it(
    "sets the NVIM_CWD environment variable to the current working directory",
    function()
      if vim.fn.has("nvim-0.11") == 0 then
        return
      end

      -- selene: allow(incorrect_standard_library_use)
      os.remove = spy.new(function() end)
      vim.uv.cwd = spy.new(function()
        return "/tmp/fakedir"
      end)
      local jobstart_spy = spy.new(function() end)
      vim.fn.jobstart = jobstart_spy

      require("yazi.process.yazi_process"):start(config, { path }, {
        on_exit = function() end,
        on_ya_first_event = function() end,
      })

      local call = jobstart_spy.calls[#jobstart_spy.calls]
      assert(call)
      assert(call.vals[2])
      assert(call.vals[2].env)
      local env = call.vals[2].env

      assert.equal(env.NVIM_CWD, "/tmp/fakedir")
    end
  )
end)
