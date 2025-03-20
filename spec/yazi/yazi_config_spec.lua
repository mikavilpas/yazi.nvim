local assert = require("luassert")
local reset = require("spec.yazi.helpers.reset")

local winborder_available = pcall(function()
  -- it's only available for nightly 0.11+, see
  -- https://github.com/neovim/neovim/pull/31074
  --
  -- will fail on stable neovim right now, so use pcall to avoid an error
  return vim.o.winborder
end)

local function if_winborder_supported(fn)
  -- prevent tests failing on stable
  if winborder_available then
    fn()
  else
    print("`vim.o.winborder` is not supported, skipping")
  end
end

describe("the default config", function()
  before_each(function()
    reset.clear_all_buffers()
    reset.close_all_windows()
    if_winborder_supported(function()
      vim.o.winborder = "solid"
    end)
  end)

  describe("`yazi_floating_window_border`", function()
    it("sets it to the default value if not set", function()
      if_winborder_supported(function()
        vim.o.winborder = ""
        local config = require("yazi.config").default()
        assert.same("rounded", config.yazi_floating_window_border)
      end)
    end)

    it("allows customizing it with the `vim.o.winborder` option", function()
      if_winborder_supported(function()
        vim.o.winborder = "single"
        local config = require("yazi.config").default()
        assert.same("single", config.yazi_floating_window_border)
      end)
    end)

    it("yazi.setup() allows customizing it", function()
      if_winborder_supported(function()
        vim.o.winborder = "double"
        require("yazi").setup({ yazi_floating_window_border = "single" })
        assert.same(
          "single",
          require("yazi").config.yazi_floating_window_border
        )
      end)
    end)
  end)
end)
