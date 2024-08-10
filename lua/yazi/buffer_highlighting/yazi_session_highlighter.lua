local Log = require("yazi.log")
local utils = require("yazi.utils")
local WindowHighlight = require("yazi.buffer_highlighting.window_highlight")

---@alias WindowId integer

--- When yazi is open, this class is responsible for highlighting buffers. This
--- is useful because the highlights need to be changed when new files are
--- hovered in yazi. When yazi is closed, the highlights can be removed.
---@class YaziSessionHighlighter
---@field window_highlights table<WindowId, yazi.WindowHighlight> The currently highlighted windows
local YaziSessionHighlighter = {}
YaziSessionHighlighter.__index = YaziSessionHighlighter

function YaziSessionHighlighter.new()
  local self = setmetatable({}, YaziSessionHighlighter)
  self.window_highlights = {}
  return self
end

function YaziSessionHighlighter:clear_highlights()
  for _, hl in pairs(self.window_highlights) do
    pcall(hl.reset_to_normal, hl)
  end

  self.window_highlights = {}
end

---@param url string
---@param config YaziConfig
function YaziSessionHighlighter:highlight_buffers_when_hovered(url, config)
  local highlight_config = config.highlight_groups
  assert(highlight_config, "highlight_config is required")

  local visible_open_buffers = utils.get_visible_open_buffers()

  Log:debug(
    string.format(
      "Calculating the highlights for %d buffers",
      #visible_open_buffers
    )
  )

  for _, buffer in ipairs(visible_open_buffers) do
    local whl = self.window_highlights[buffer.window_id]
    if not whl then
      whl = WindowHighlight.new(buffer.window_id)
      self.window_highlights[buffer.window_id] = whl
    end

    if buffer.renameable_buffer:matches_exactly(url) then
      Log:debug(
        "highlighting exactly matching buffer "
          .. buffer.renameable_buffer.bufnr
          .. " in window "
          .. buffer.window_id
      )

      -- the color is a bit more intense than the sibling buffer, signifying
      -- "this is the hovered buffer"
      whl:set_highlight(
        highlight_config.hovered_buffer,
        "YaziBufferHovered",
        { when_light = -25, when_dark = 65 }
      )
    elseif
      buffer.renameable_buffer:is_sibling_of_hovered(url)
      and config.highlight_hovered_buffers_in_same_directory == true
    then
      Log:debug(
        "highlighting sibling buffer "
          .. buffer.renameable_buffer.bufnr
          .. " in window "
          .. buffer.window_id
      )

      -- the color is a bit less intense than the hovered buffer, signifying
      -- "you are close to the hovered buffer"
      whl:set_highlight(
        highlight_config.hovered_buffer_in_same_directory,
        "YaziBufferHoveredInSameDirectory",
        { when_light = -10, when_dark = 20 }
      )
    else
      whl:reset_to_normal()
    end
  end
end

return YaziSessionHighlighter
