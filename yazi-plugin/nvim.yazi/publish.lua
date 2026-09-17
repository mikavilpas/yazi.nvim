--- @since 25.5.31

local M = {}

-- Send the event to yazi.nvim.
--
-- `ps.pub` publishes locally, which makes yazi report the event on its own
-- stdout when it was started with `--local-events=yazi-nvim`. `ps.pub_to(0,
-- ...)` instead broadcasts to *remote* peers only, which is what the separate
-- `ya sub` process listens to.
---@param payload table
local function publish(payload)
  if os.getenv("YAZI_NVIM_LOCAL_EVENTS") ~= nil then
    ps.pub("yazi-nvim", payload)
  else
    ps.pub_to(0, "yazi-nvim", payload)
  end
end

-- Publish the DDS event for a keymap action, so yazi.nvim receives it. Then
-- yazi.nvim can react to the action. This kind of design allows yazi to own
-- the keymaps, so that yazi.nvim doesn't have to guess when it should
-- intercept them (e.g. when the user is in an input mode like bulk rename,
-- filter, or find).
M.keymap_event = ya.sync(function(_, action)
  local neovim_id =
    assert(os.getenv("YAZI_NVIM_ID"), "YAZI_NVIM_ID must be set")

  if action == "change_working_directory" then
    local cwd = cx.active.current.cwd
    assert(cwd, "expected to find the yazi cwd")
    publish({
      action = action,
      yazi_id = neovim_id,
      cwd = tostring(cwd),
    })
  else
    local hovered = cx.active.current.hovered

    local selected = {}
    for _, url in pairs(cx.active.selected) do
      selected[#selected + 1] = tostring(url)
    end

    publish({
      action = action,
      yazi_id = neovim_id,
      hovered = hovered and tostring(hovered.url) or nil,
      selected = selected,
    })
  end
end)

return M
