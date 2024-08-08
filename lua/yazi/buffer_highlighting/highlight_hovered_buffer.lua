local Log = require("yazi.log")
local utils = require("yazi.utils")
local DisposableHighlight =
  require("yazi.buffer_highlighting.disposable_highlight")

local M = {}

---@alias WindowId integer

-- The currently highlighted windows. Global because there can only be one yazi
-- at a time.
---@type table<WindowId, yazi.DisposableHighlight>
local window_highlights = {}

function M.clear_highlights()
  for _, hl in pairs(window_highlights) do
    pcall(hl.dispose, hl)
  end

  window_highlights = {}
end

---@param url string
---@param highlight_config YaziConfigHighlightGroups
function M.highlight_hovered_buffer(url, highlight_config)
  assert(highlight_config, "highlight_config is required")

  local visible_open_buffers = utils.get_visible_open_buffers()
  for _, buffer in ipairs(visible_open_buffers) do
    if buffer.renameable_buffer:matches_exactly(url) then
      local existing_hl = window_highlights[buffer.window_id]
      if existing_hl == nil then
        Log:debug(
          "highlighting buffer "
            .. buffer.renameable_buffer.bufnr
            .. " in window "
            .. buffer.window_id
        )

        window_highlights[buffer.window_id] =
          DisposableHighlight.new(buffer.window_id, highlight_config)
      end
    else
      -- only one file can be hovered at a time, so let's clear
      -- the highlight
      local hl = window_highlights[buffer.window_id]
      if hl ~= nil then
        local success = pcall(hl.dispose, hl)
        window_highlights[buffer.window_id] = nil
        if success then
          Log:debug(
            "disposed of highlight for buffer "
              .. buffer.renameable_buffer.bufnr
              .. " in window "
              .. buffer.renameable_buffer.bufnr
          )
        else
          Log:debug(
            "failed to dispose of highlight for buffer "
              .. buffer.renameable_buffer.bufnr
              .. " in window "
              .. buffer.window_id
          )
        end
      end
    end
  end
end

return M
