local Log = require('yazi.log')

---@class yazi.DisposableHighlight
---@field private old_winhighlight string
---@field private window_id integer
local DisposableHighlight = {}
DisposableHighlight.__index = DisposableHighlight

---@param window_id integer
---@param highlight_config YaziConfigHighlightGroups
function DisposableHighlight.new(window_id, highlight_config)
  local self = setmetatable({}, DisposableHighlight)
  self.window_id = window_id
  self.old_winhighlight = vim.wo.winhighlight

  vim.api.nvim_set_hl(
    0,
    'YaziBufferHoveredBackground',
    highlight_config.hovered_buffer_background
  )

  vim.api.nvim_set_option_value(
    'winhighlight',
    'Normal:YaziBufferHoveredBackground',
    { win = window_id }
  )

  return self
end

function DisposableHighlight:dispose()
  Log:debug(
    string.format(
      'Disposing of the DisposableHighlight for window_id %s',
      self.window_id
    )
  )
  -- Revert winhighlight to its old value
  if vim.api.nvim_win_is_valid(self.window_id) then
    vim.api.nvim_set_option_value('winhighlight', self.old_winhighlight, {
      win = self.window_id,
    })
  end
end

return DisposableHighlight
