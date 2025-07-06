---@module "yazi"

local yazi = require("yazi")

-- selene: allow(unused_variable)
---@param path string
function Yazi_is_hovering(path)
  ---@type YaziActiveContext
  local current = assert(
    yazi.active_contexts:peek(),
    "No active context found. Is yazi running?."
  )

  local hovered = current.hovered_file

  assert(
    hovered == path,
    string.format(
      "Expected yazi '%s' to be hovering '%s', but found '%s'",
      current.api.yazi_id,
      path,
      hovered
    )
  )
end

-- selene: allow(unused_variable)
---@param path string
function Yazi_is_in_directory(path)
  ---@type YaziActiveContext
  local current = assert(
    yazi.active_contexts:peek(),
    "No active context found. Is yazi running?."
  )

  local cwd = assert(current.cwd, "No cwd found in the YaziActiveContext.")
  local relative_cwd = vim.fn.fnamemodify(cwd, ":~")

  assert(
    relative_cwd == path or relative_cwd == "~/" .. path,
    string.format(
      "Expected yazi '%s' to be in directory '%s', but found '%s'",
      current.api.yazi_id,
      path,
      cwd
    )
  )
end

-- selene: allow(unused_variable)
function Yazi_is_ready()
  ---@type YaziActiveContext
  local current = assert(
    yazi.active_contexts:peek(),
    "No active context found. Is yazi running?."
  )
  local ready, details = current.ya_process:is_ready(current.api.yazi_id)
  assert(ready, "Yazi is not ready yet. Details: " .. vim.inspect(details))
end
