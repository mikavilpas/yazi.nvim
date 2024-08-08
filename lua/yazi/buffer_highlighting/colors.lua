local M = {}

---@param color string
function M.hex2rgb(color)
  color = color:gsub("#", "")
  local r = color:sub(1, 2)
  local g = color:sub(3, 4)
  local b = color:sub(5, 6)
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

---@param i integer
function M.rgb2hex(i)
  return string.format("%06x", i)
end

---@param attr number
---@param percent number
function M.alter(attr, percent)
  return math.floor(attr * (100 + percent) / 100)
end

---@param color string
---@param percent number
function M.darken_or_lighten_percent(color, percent)
  local r, g, b = M.hex2rgb(color)
  r = M.alter(r, percent)
  r = math.min(r, 255)
  r = math.max(r, 0)

  g = M.alter(g, percent)
  g = math.min(g, 255)
  g = math.max(g, 0)

  b = M.alter(b, percent)
  b = math.min(b, 255)
  b = math.max(b, 0)

  return ("#%02x%02x%02x"):format(r, g, b)
end

-- from https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/utils/colors.lua#L75C1-L83C4
---@param r number
---@param g number
---@param b number
function M.color_is_bright(r, g, b)
  -- Counting the perceptive luminance - human eye favors green color
  local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  if luminance > 0.5 then
    return true -- Bright colors, black font
  else
    return false -- Dark colors, text font
  end
end

return M
