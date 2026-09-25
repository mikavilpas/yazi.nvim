--- @since 25.5.31

local M = {}

-- Publish the DDS event for a keymap action, so yazi.nvim's `ya sub` receives
-- it. Then yazi.nvim can react to the action. This kind of design allows yazi
-- to own the keymaps, so that yazi.nvim doesn't have to guess when it should
-- intercept them (e.g. when the user is in an input mode like bulk rename,
-- filter, or find).
-- Render a yazi url as a plain file system path.
--
-- A file shown inside a "view" (yazi's virtual file system, used for search
-- results) has a url that also describes the view it was found in, such as
-- `fd://default:2:2/@d312safile_3.txt1aA1h0//home/user/file.txt`. Neovim can
-- only work with the physical file, so send that instead of the url.
--
-- `physical` was added along with views; on older yazi versions the url is
-- already a plain path.
---@param url any a yazi `Url`
---@return string
local function physical_path(url)
  return tostring(url.physical or url)
end

M.keymap_event = ya.sync(function(_, action)
  local neovim_id =
    assert(os.getenv("YAZI_NVIM_ID"), "YAZI_NVIM_ID must be set")

  if action == "change_working_directory" then
    local cwd = cx.active.current.cwd
    assert(cwd, "expected to find the yazi cwd")
    ps.pub_to(0, "yazi-nvim", {
      action = action,
      yazi_id = neovim_id,
      cwd = physical_path(cwd),
    })
  else
    local hovered = cx.active.current.hovered

    local selected = {}
    for _, url in pairs(cx.active.selected) do
      selected[#selected + 1] = physical_path(url)
    end

    ps.pub_to(0, "yazi-nvim", {
      action = action,
      yazi_id = neovim_id,
      hovered = hovered and physical_path(hovered.url) or nil,
      selected = selected,
    })
  end
end)

return M
