local assert = require("luassert")
local ya_process = require("yazi.process.ya_process")

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
end)
