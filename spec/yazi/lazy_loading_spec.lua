local assert = require("luassert")

describe("lazy loading", function()
  before_each(function()
    -- clear all buffers
    for k, _ in pairs(package.loaded) do
      if k:sub(1, 4) == "yazi" then
        package.loaded[k] = nil
      end
    end
  end)

  it("is found for a visible buffer editing a file", function()
    -- The idea is that yazi.nvim exposes its public functions when you call
    -- `require("yazi")`. It should load as little code up front as possible,
    -- because some users don't use a package manager like lazy.nvim that
    -- supports lazy loading modules by default.
    require("yazi").setup({})

    local yazi_modules = {}
    for k, _ in pairs(package.loaded) do
      if k:sub(1, 4) == "yazi" then
        table.insert(yazi_modules, k)
      end
    end

    -- Not sure what would be a good way to test lazy loading. For now, just
    -- load the plugin and see how many modules have been loaded.
    --
    -- Maybe in the future, we can have a better way to do this.
    table.sort(yazi_modules)
    assert.are.same(yazi_modules, {
      "yazi",
      "yazi.config",
      "yazi.log",
      "yazi.openers",
    })
  end)
end)
