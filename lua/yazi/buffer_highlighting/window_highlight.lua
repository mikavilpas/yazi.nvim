local Log = require("yazi.log")

--- A stateful highlight status for a window. Can change the background color
--- into a new color, and revert it back to the original color.
---@class yazi.WindowHighlight
---@field private first_winhighlight string
---@field private window_id integer
local WindowHighlight = {}
WindowHighlight.__index = WindowHighlight

---@param window_id integer
function WindowHighlight.new(window_id)
  local self = setmetatable({}, WindowHighlight)

  self.first_winhighlight =
    vim.api.nvim_get_option_value("winhighlight", { win = window_id })

  self.window_id = window_id

  return self
end

---@alias YaziLightenOrDarkenPercent {when_light: number, when_dark: number}

---@param lighten_or_darken YaziLightenOrDarkenPercent
local function create_hover_color_from_theme(lighten_or_darken)
  -- the user has not defined a custom highlight color, so let's create one
  local colors = require("yazi.buffer_highlighting.colors")
  local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })

  if (not hl) or not hl.bg then
    return
  end

  local bg_hex = colors.rgb2hex(hl.bg)
  local r, g, b = colors.hex2rgb(bg_hex)

  if colors.color_is_bright(r, g, b) then
    local bg =
      colors.darken_or_lighten_percent(bg_hex, lighten_or_darken.when_light)
    return { bg = bg, force = true }
  else
    local bg =
      colors.darken_or_lighten_percent(bg_hex, lighten_or_darken.when_dark)
    return { bg = bg, force = true }
  end
end

---@param highlight? vim.api.keyset.highlight
---@param highlight_name string
---@param lighten_or_darken YaziLightenOrDarkenPercent
function WindowHighlight:set_highlight(
  highlight,
  highlight_name,
  lighten_or_darken
)
  -- `force = true` overrides the existing highlight group - so that the user
  -- can see the correct color if they switch colorschemes without restarting
  if highlight ~= nil then
    vim.api.nvim_set_hl(0, highlight_name, highlight)
  else
    local color = create_hover_color_from_theme(lighten_or_darken)
    if color == nil then
      Log:debug("Could not find a background color, not highlighting")

      return
    end
    vim.api.nvim_set_hl(0, highlight_name, color)
  end

  Log:debug(
    string.format("Setting winhighlight for window_id %s", self.window_id)
  )

  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:" .. highlight_name,
    { win = self.window_id }
  )
end

function WindowHighlight:reset_to_normal()
  if vim.api.nvim_win_is_valid(self.window_id) then
    -- Revert winhighlight to its old value
    Log:debug(
      string.format(
        "Disposing of the DisposableHighlight for window_id %s",
        self.window_id
      )
    )
    vim.api.nvim_set_option_value("winhighlight", self.first_winhighlight, {
      win = self.window_id,
    })
  end
end

return WindowHighlight
