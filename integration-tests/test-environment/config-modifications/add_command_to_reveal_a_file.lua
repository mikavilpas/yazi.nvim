local M = {}

--- Reveal (hover) `path` in our yazi instance and block until our yazi confirms
--- it is hovering that path.
---
--- @param path string
function M.reveal_path_and_wait_for_hover(path)
  local yazi = require("yazi")
  local Log = require("yazi.log")

  ---@type YaziActiveContext | nil
  local context = yazi.active_contexts:current()
  if not context then
    error("No active yazi context found. Is yazi running?")
  end

  Log:debug("Revealing path in yazi context: " .. vim.inspect(path))

  -- yazi only emits a `hover` DDS event when the hovered item actually
  -- *changes*. The `hover` event yazi sends back in response to a `reveal` can
  -- be lost in CI, which leaves our `hovered_url` stuck on the previous path
  -- even though yazi's cursor is already on `path`. Re-emitting `reveal path`
  -- is then a no-op: the cursor is already there, so yazi emits nothing new
  -- and we would wait forever.
  --
  -- To break out of that, each attempt first reveals a *different* decoy path
  -- to force the cursor away, then reveals `path` again. Approaching `path`
  -- from elsewhere guarantees yazi emits a fresh `hover` event, so every
  -- attempt gets an independent chance to be observed instead of hanging on a
  -- single event that may never arrive. The decoy is the last known
  -- `hovered_url`: it is a real, existing path, and whenever we still need to
  -- retry it differs from `path` (otherwise we'd already be done).
  local attempts = 20
  local interval_ms = 150

  -- `ya emit-to` can fail without yazi ever seeing the command, e.g. when the
  -- DDS socket is gone ("Connection refused").
  ---@type string | nil
  local last_emit_error = nil

  ---@param job vim.SystemObj
  ---@param what string
  local function reveal_and_check(job, what)
    local result = job:wait(1000)
    if result.code ~= 0 then
      last_emit_error = string.format(
        "revealing %s exited with code %s: '%s'",
        what,
        result.code,
        vim.trim(result.stderr or "")
      )
      Log:debug("`ya emit-to` failed: " .. last_emit_error)
    end
  end

  for _ = 1, attempts do
    if context.ya_process.hovered_url == path then
      return
    end

    local decoy = context.ya_process.hovered_url
    if type(decoy) == "string" and decoy ~= path then
      -- Wait for the decoy reveal to be delivered before revealing the target,
      -- so yazi clearly processes them as two distinct moves rather than
      -- coalescing them into a single no-op cursor update.
      reveal_and_check(
        context.api:reveal(decoy),
        string.format("the decoy '%s'", decoy)
      )
    end

    reveal_and_check(context.api:reveal(path), string.format("'%s'", path))
    local hovered = vim.wait(interval_ms, function()
      return context.ya_process.hovered_url == path
    end, 20)
    if hovered then
      return
    end
  end

  local reason = last_emit_error ~= nil
      and string.format(
        " The last `ya emit-to` failure was: %s",
        last_emit_error
      )
    or " Every `ya emit-to` succeeded, so yazi received the reveals but never reported hovering the path."

  error(
    string.format(
      "Timed out waiting for yazi to hover '%s'. Last hovered url: '%s'.%s",
      path,
      tostring(context.ya_process.hovered_url),
      reason
    )
  )
end

return M
