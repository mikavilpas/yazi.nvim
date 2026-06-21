local M = {}

--- Reveal (hover) `path` in our yazi instance and block until our yazi confirms
--- it is hovering that path.
---
--- @param path string
function M.reveal_path_and_wait_for_hover(path)
  local yazi = require("yazi")
  local Log = require("yazi.log")

  ---@type YaziActiveContext | nil
  local context = yazi.active_contexts:peek()
  if not context then
    error("No active yazi context found. Is yazi running?")
  end

  Log:debug("Revealing path in yazi context: " .. vim.inspect(path))

  local attempts = 20
  local interval_ms = 100
  for _ = 1, attempts do
    context.api:reveal(path)
    local hovered = vim.wait(interval_ms, function()
      return context.ya_process.hovered_url == path
    end, 20)
    if hovered then
      return
    end
  end

  error(
    string.format(
      "Timed out waiting for yazi to hover '%s'. Last hovered url: '%s'",
      path,
      tostring(context.ya_process.hovered_url)
    )
  )
end

return M
