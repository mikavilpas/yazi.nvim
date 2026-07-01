--- @since 25.5.31

-- Keymap registration for nvim.yazi.
--
-- yazi.nvim serializes the user's configured `plugin_keymaps` into the
-- `YAZI_NVIM_PLUGIN_KEYMAPS` environment variable (see
-- `lua/yazi/plugin_keymaps.lua`). This module parses them and registers each as
-- a dynamic yazi keymap via `km.mgr.rules`.

local M = {}

-- Read the keymaps yazi.nvim passed via the environment. One record per line,
-- tab-separated fields `on\taction\tdesc`.
---@param raw string
---@return { on: string, action: string, desc?: string }[]
function M.parse_from_env(raw)
  if raw == nil or raw == "" then
    return {}
  end

  local keymaps = {}
  for line in raw:gmatch("[^\n]+") do
    local on, action, desc = line:match("^(.-)\t(.-)\t(.*)$")
    if on and action then
      keymaps[#keymaps + 1] = { on = on, action = action, desc = desc }
    end
  end
  return keymaps
end

-- Register each keymap inside yazi via the dynamic keymap API. Pressing a key
-- runs `plugin nvim -- <action>`, which invokes this plugin's `entry` and
-- publishes a DDS event that yazi.nvim reacts to.
---@param keymaps { on: string, action: string, desc?: string }[]
function M.register(keymaps)
  for _, mapping in ipairs(keymaps) do
    km.mgr.rules:insert(1, {
      on = mapping.on,
      run = string.format("plugin nvim -- %s", mapping.action),
      desc = mapping.desc,
    })
  end
end

return M
