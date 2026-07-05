--- @since 25.5.31

local M = {}

-- Publish the DDS event for a keymap action, so yazi.nvim's `ya sub` receives
-- it. Then yazi.nvim can react to the action. This kind of design allows yazi
-- to own the keymaps, so that yazi.nvim doesn't have to guess when it should
-- intercept them (e.g. when the user is in an input mode like bulk rename,
-- filter, or find).
M.keymap_event = ya.sync(function(_, action)
  local hovered = cx.active.current.hovered

  local selected = {}
  for _, url in pairs(cx.active.selected) do
    selected[#selected + 1] = tostring(url)
  end

  -- Send everything yazi.nvim might need so it can stay stateless (spike
  -- decision #2). yazi_id lets yazi.nvim ignore events from other yazi
  -- instances; if the env var is unavailable it stays nil and yazi.nvim simply
  -- doesn't filter (fine for a single instance).
  ps.pub_to(0, "yazi-nvim", {
    action = action,
    yazi_id = os.getenv("YAZI_NVIM_ID"),
    hovered = hovered and tostring(hovered.url) or nil,
    selected = selected,
  })
end)

return M
