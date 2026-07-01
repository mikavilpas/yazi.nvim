--- @since 25.5.31

-- Status bar indicator for nvim.yazi.
-- This is useful for e2e tests since they assert on output on the screen.
local M = {}

local ICON = "\u{f36f}" -- nf-linux-neovim, ""

function M.setup()
  Status:children_add(function()
    return ui.Line({
      ui.Span(" " .. ICON .. " "):fg("#57a143"):dim(),
    })
  end, 500, Status.RIGHT)
end

return M
