local assert = require("luassert")
local colors = require("yazi.buffer_highlighting.colors")

local function rgb_to_hex(i)
  return string.format("%02x", i)
end

describe("color modification", function()
  it("can convert a hex color to rgb", function()
    local hex_color = "#ff0000"
    local r, g, b = colors.hex2rgb(hex_color)

    assert.same({ 255, 0, 0 }, { r, g, b })
  end)

  describe("altering a color", function()
    it("can alter a color by increasing it", function()
      local attr = 100
      local altered = colors.alter(attr, 10)

      assert.same(altered, 110)
    end)

    it("can alter a color by decreasing it", function()
      local attr = 100
      local altered = colors.alter(attr, -10)

      assert.same(altered, 90)
    end)

    it("does no checking of bounds", function()
      assert.same(colors.alter(255, 10), 280)
      assert.same(colors.alter(100, -150), -50)
    end)
  end)

  describe("darken_or_lighten_percent", function()
    -- there are some sanity check to help grug brains like me to read this

    it("can darken the red color channel", function()
      local color = "#ff0000"
      assert.same("ff", rgb_to_hex(255))

      local modified = colors.darken_or_lighten_percent(color, -10)

      assert.same("#e50000", modified)
      assert.same("#" .. rgb_to_hex(255 * 0.9) .. "0000", modified)
    end)

    it("can lighten the red color channel", function()
      local color = "#640000"
      assert.same("64", rgb_to_hex(100))

      local modified = colors.darken_or_lighten_percent(color, 10)

      assert.same("#6e0000", modified)
      assert.same("#" .. rgb_to_hex(100 * 1.1) .. "0000", modified)
    end)

    it("can lighten all channels", function()
      local color = "#646464"
      assert.same("64", rgb_to_hex(100))

      local modified = colors.darken_or_lighten_percent(color, 10)

      assert.same("#6e6e6e", modified)
      assert.same(
        "#"
          .. rgb_to_hex(100 * 1.1)
          .. rgb_to_hex(100 * 1.1)
          .. rgb_to_hex(100 * 1.1),
        modified
      )
    end)

    it("can darken all channels", function()
      local color = "#646464"
      assert.same("64", rgb_to_hex(100))

      local modified = colors.darken_or_lighten_percent(color, -10)

      assert.same("#5a5a5a", modified)
      assert.same(
        "#"
          .. rgb_to_hex(100 * 0.9)
          .. rgb_to_hex(100 * 0.9)
          .. rgb_to_hex(100 * 0.9),
        modified
      )
    end)

    it("limits the color's value to 255, the max value", function()
      local color = "#ffffff"
      assert.same("ff", rgb_to_hex(255))

      local modified = colors.darken_or_lighten_percent(color, 100)

      assert.same("#ffffff", modified)
      assert.same("#ffffff", modified)
    end)

    it("limits the color's value to 0, the min value", function()
      local color = "#010101"
      assert.same("01", rgb_to_hex(1))

      local modified = colors.darken_or_lighten_percent(color, -200)

      assert.same("#000000", modified)
      assert.same("#000000", modified)
    end)
  end)

  describe("color_is_bright", function()
    -- the algorithm is described here
    -- https://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color/1855903#1855903
    --
    -- but for this use case we don't need to test it too much - just some
    -- basic test cases should do
    it("can determine if a color is bright", function()
      local r, g, b = 255, 255, 255
      assert.is_true(colors.color_is_bright(r, g, b))

      r, g, b = 0, 0, 0
      assert.is_false(colors.color_is_bright(r, g, b))

      r, g, b = 255, 0, 0
      assert.is_false(colors.color_is_bright(r, g, b))

      r, g, b = 0, 255, 0
      assert.is_true(colors.color_is_bright(r, g, b))

      r, g, b = 0, 0, 255
      assert.is_false(colors.color_is_bright(r, g, b))
    end)
  end)
end)
