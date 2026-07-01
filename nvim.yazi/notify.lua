--- @since 25.5.31

-- Error reporting for nvim.yazi.
--
-- When something in the plugin fails (a bad keymap, a failed DDS publish, a
-- module that won't load), surface it to the user as a yazi notification
-- instead of failing silently.
local M = {}

-- Show an error notification and mirror it to yazi's log.
---@param message string
function M.error(message)
  local text = "nvim.yazi: " .. message
  ya.err(text)
  ya.notify({
    title = "yazi.nvim",
    content = text,
    level = "error",
    timeout = 60,
  })
end

-- Run `fn`, reporting any error as a notification rather than letting it surface
-- as an unhandled yazi plugin failure. `context` describes what was being
-- attempted and is prefixed to the message. Returns `fn`'s result on success, or
-- `nil` if it raised.
---@generic T
---@param context string
---@param fn fun(): T
---@return T?
function M.guard(context, fn)
  local ok, result = pcall(fn)
  if not ok then
    M.error(string.format("%s: %s", context, tostring(result)))
    return nil
  end
  return result
end

return M
