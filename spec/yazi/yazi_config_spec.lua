local assert = require("luassert")
local reset = require("spec.yazi.helpers.reset")

describe("the default config", function()
  before_each(function()
    reset.clear_all_buffers()
    reset.close_all_windows()
    vim.o.winborder = "solid"
  end)

  describe("`yazi_floating_window_border`", function()
    it("sets it to the default value if not set", function()
      vim.o.winborder = ""
      local config = require("yazi.config").default()
      assert.same("rounded", config.yazi_floating_window_border)
    end)

    it("allows customizing it with the `vim.o.winborder` option", function()
      vim.o.winborder = "single"
      local config = require("yazi.config").default()
      assert.same("single", config.yazi_floating_window_border)
    end)

    it("yazi.setup() allows customizing it", function()
      vim.o.winborder = "double"
      require("yazi").setup({ yazi_floating_window_border = "single" })
      assert.same("single", require("yazi").config.yazi_floating_window_border)
    end)
  end)
end)
