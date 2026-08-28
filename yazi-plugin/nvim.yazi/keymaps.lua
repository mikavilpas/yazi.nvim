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
---@param rules? { insert: fun(self: any, index: integer, rule: table) }
function M.register(keymaps, rules)
  rules = rules or km.mgr.rules
  for _, mapping in ipairs(keymaps) do
    rules:insert(1, {
      on = mapping.on,
      run = string.format("plugin nvim -- %s", mapping.action),
      desc = mapping.desc,
    })
  end
end

---@param rules? { insert: fun(self: any, index: integer, rule: table) }
function M.register_guarded_open(rules)
  M.register({
    {
      on = "<Enter>",
      action = "guarded_open",
      desc = "yazi.nvim: open selected files",
    },
  }, rules)
end

---@param selected { cha: { is_dir: boolean } }[]
---@return boolean
function M.should_open(selected)
  for _, file in pairs(selected) do
    if file.cha.is_dir then
      return false
    end
  end

  return true
end

return M
