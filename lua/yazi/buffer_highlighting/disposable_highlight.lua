local Log = require('yazi.log')

---@class yazi.DisposableHighlight
---@field private old_winhighlight string
---@field private window_id integer
local DisposableHighlight = {}
DisposableHighlight.__index = DisposableHighlight

local function create_hover_color_from_theme()
  -- the user has not defined a custom highlight color, so let's create one
  -- for them
  local colors = require('bufferline.colors')
  local hex = colors.get_color

  local bg = hex({ name = 'Normal', attribute = 'bg' })

  if bg == nil then
    return
  end

  if colors.color_is_bright(bg) then
    return { bg = colors.shade_color(bg, -20), force = true }
  else
    return { bg = colors.shade_color(bg, 60), force = true }
  end
end

---@param window_id integer
---@param highlight_config YaziConfigHighlightGroups
function DisposableHighlight.new(window_id, highlight_config)
  local self = setmetatable({}, DisposableHighlight)
  self.window_id = window_id
  self.old_winhighlight = vim.wo.winhighlight

  -- `force = true` overrides the existing highlight group - so that the user
  -- can see the correct color if they switch colorschemes without restarting
  if highlight_config.hovered_buffer ~= nil then
    vim.api.nvim_set_hl(0, 'YaziBufferHovered', highlight_config.hovered_buffer)
  else
    local color = create_hover_color_from_theme()
    if color == nil then
      Log:debug(
        'Could not find a background color for a hovered_buffer, not highlighting'
      )

      return
    end
    vim.api.nvim_set_hl(0, 'YaziBufferHovered', color)
  end

  vim.api.nvim_set_option_value(
    'winhighlight',
    'Normal:YaziBufferHovered',
    { win = window_id }
  )

  return self
end

function DisposableHighlight:dispose()
  if vim.api.nvim_win_is_valid(self.window_id) then
    -- Revert winhighlight to its old value
    Log:debug(
      string.format(
        'Disposing of the DisposableHighlight for window_id %s',
        self.window_id
      )
    )
    vim.api.nvim_set_option_value('winhighlight', self.old_winhighlight, {
      win = self.window_id,
    })
  end
end

return DisposableHighlight
