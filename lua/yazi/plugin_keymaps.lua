local M = {}

-- The environment variable the serialized keymaps are passed through.
M.env_var = "YAZI_NVIM_PLUGIN_KEYMAPS"

--- Serialize `plugin_keymaps` into a string the `nvim.yazi` yazi plugin can parse.
---
--- yazi's plugin Lua sandbox has no JSON available, so a simple line/tab-delimited
--- format is used: one record per line, fields separated by tabs
--- (`on\taction\tdesc`). Yazi keys, action ids, and the generated descriptions
--- never contain tabs or newlines, so the encoding is unambiguous. The records are
--- sorted so the output is deterministic (nicer for tests and logs).
---
--- @param plugin_keymaps YaziPluginKeymaps
--- @return string
function M.serialize(plugin_keymaps)
  local records = {}
  for action, key in pairs(plugin_keymaps) do
    if key ~= false and key ~= nil then
      local desc = "yazi.nvim: " .. (action:gsub("_", " "))
      records[#records + 1] = table.concat({ key, action, desc }, "\t")
    end
  end
  table.sort(records)
  return table.concat(records, "\n")
end

return M
