local assert = require("luassert")
local mock = require("luassert.mock")

local plugin = require("yazi")

describe("open_for_directories", function()
  local hijack_netrw = mock(require("yazi.hijack_netrw"), true)
  before_each(function()
    mock.clear(hijack_netrw)
  end)

  it("sets up hijack_netrw when `open_for_directories` has been set", function()
    plugin.setup({ open_for_directories = true })

    -- instead of netrw opening, yazi should open
    vim.api.nvim_command("edit /")

    assert.spy(hijack_netrw.hijack_netrw).was_called(1)
  end)

  it(
    "does not set up hijack_netrw when `open_for_directories` is falsy",
    function()
      plugin.setup({ open_for_directories = false })

      -- instead of netrw opening, yazi should open
      vim.api.nvim_command("edit /")

      assert.spy(hijack_netrw.hijack_netrw).was_not_called()
    end
  )
end)
