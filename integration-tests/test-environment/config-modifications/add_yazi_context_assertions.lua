---@module "yazi"

local yazi = require("yazi")

---The yazi that was started most recently. Tests that open yazi more than once
---must look at that one - an older context describes a yazi that has already
---exited.
---@return YaziActiveContext
local function current_context()
  return assert(
    yazi.active_contexts:current(),
    "No active context found. Is yazi running?."
  )
end

-- selene: allow(unused_variable)
---@param path string
function Yazi_is_hovering(path)
  local current = current_context()

  local yazi_id = current.ya_process.yazi_id
  local hovered = current.ya_process.hovered_url

  assert(
    hovered == path,
    string.format(
      "Expected yazi '%s' to be hovering '%s', but found '%s'",
      yazi_id,
      path,
      hovered
    )
  )
end

-- selene: allow(unused_variable)
function Yazi_is_ready()
  local current = current_context()

  local ready = current.ya_process:is_ready()
  if not ready then
    local all_details = {}

    for _, value in ipairs(yazi.active_contexts:all()) do
      local _, details = value.ya_process:is_ready()
      table.insert(all_details, details)
    end

    assert(
      ready,
      "Yazi is not ready yet. Details (newest first): "
        .. vim.inspect(all_details)
    )
  end
end
