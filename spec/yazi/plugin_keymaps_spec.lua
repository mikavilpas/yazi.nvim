local assert = require("luassert")
local plugin_keymaps = require("yazi.plugin_keymaps")

describe("plugin_keymaps.serialize", function()
  it("serializes an action/key pair into a tab-delimited record", function()
    local result = plugin_keymaps.serialize({
      open_file_in_vertical_split = "<c-v>",
    })

    assert.equal(
      "<c-v>\topen_file_in_vertical_split\tyazi.nvim: open file in vertical split",
      result
    )
  end)

  it("serializes multiple keymaps deterministically (sorted)", function()
    local result = plugin_keymaps.serialize({
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
    })

    assert.equal(
      "<c-v>\topen_file_in_vertical_split\tyazi.nvim: open file in vertical split\n"
        .. "<c-x>\topen_file_in_horizontal_split\tyazi.nvim: open file in horizontal split",
      result
    )
  end)

  it("skips keymaps that are disabled (false) or nil", function()
    local result = plugin_keymaps.serialize({
      open_file_in_vertical_split = false,
    })

    assert.equal("", result)
  end)

  it("returns an empty string for an empty table", function()
    assert.equal("", plugin_keymaps.serialize({}))
  end)
end)
