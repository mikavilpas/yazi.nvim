---@module "plenary.path"

---@class(exact) YaProcessSingleton
---@field ya YaProcess | nil
local YaProcessSingleton = {}
---@diagnostic disable-next-line: inject-field
YaProcessSingleton.__index = YaProcessSingleton

---@param config YaziConfig
---@param yazi_id string
---@diagnostic disable-next-line: inject-field
function YaProcessSingleton.new(config, yazi_id)
  local self = setmetatable({}, YaProcessSingleton)
  local ya = YaProcessSingleton.ya
  if ya ~= nil and ya.is_running then
    require("yazi.log"):debug(
      string.format(
        "YaProcessSingleton is already running when starting yazi_id: %s. Reusing the existing YaProcess.",
        yazi_id
      )
    )
    return self
  end

  require("yazi.log"):debug(
    "YaProcessSingleton is not running. Creating a new YaProcess for yazi_id: "
      .. yazi_id
  )
  local YaProcess = require("yazi.process.ya_process")
  ya = YaProcess.new(config)
  YaProcessSingleton.ya = ya
  return self
end

---@param state YaziState
function YaProcessSingleton:register_yazi(state)
  local ya = assert(
    YaProcessSingleton.ya,
    "YaProcessSingleton.ya is nil. Ya should be running before registering a yazi."
  )
  ya:register_yazi(state)
end

---@param yazi_id string
---@param paths Path[]
function YaProcessSingleton:get_yazi_command(yazi_id, paths)
  return YaProcessSingleton.ya:get_yazi_command(yazi_id, paths)
end

function YaProcessSingleton:start()
  return YaProcessSingleton.ya:start()
end

---@param timeout integer
function YaProcessSingleton:kill_and_wait(timeout)
  require("yazi.log"):debug(
    string.format("YaProcessSingleton not closing - ya remains open", timeout)
  )
end

return YaProcessSingleton
