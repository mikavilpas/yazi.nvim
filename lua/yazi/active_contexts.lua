local Log = require("yazi.log")

--- A bounded, newest-first record of the yazi instances that are running.
---
--- Holds at most `capacity` contexts. Pushing beyond that drops the oldest, so a
--- context that is never removed (a missed `on_exit`) cannot accumulate.
---
---@class yazi.ActiveContexts
---@field private items YaziActiveContext[] # newest first
---@field private capacity integer
local ActiveContexts = {}
---@diagnostic disable-next-line: inject-field
ActiveContexts.__index = ActiveContexts

---@param capacity integer
---@return yazi.ActiveContexts
function ActiveContexts.new(capacity)
  assert(capacity > 0, "capacity must be positive")
  return setmetatable({ items = {}, capacity = capacity }, ActiveContexts)
end

---@param context YaziActiveContext
function ActiveContexts:push(context)
  table.insert(self.items, 1, context)

  while #self.items > self.capacity do
    local dropped = table.remove(self.items) -- the oldest
    Log:debug(
      string.format(
        "Dropping the oldest active context (%s) to stay within the capacity of %d. It was never removed - did it fail to report exiting?",
        dropped and dropped.ya_process:id() or "nil",
        self.capacity
      )
    )
  end
end

---The most recently started yazi, if any is running.
---@return YaziActiveContext?
function ActiveContexts:current()
  return self.items[1]
end

---Every context still known, newest first. A copy, so that mutating the result
---cannot affect the collection.
---@return YaziActiveContext[]
function ActiveContexts:all()
  return vim.list_slice(self.items)
end

---@param context YaziActiveContext
---@return boolean removed # false if the context was not (or no longer) known
function ActiveContexts:remove(context)
  for index, value in ipairs(self.items) do
    if value == context then
      table.remove(self.items, index)
      return true
    end
  end

  return false
end

return ActiveContexts
