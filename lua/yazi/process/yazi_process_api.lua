---@module "plenary.path"

---@class YaziProcessApi # Provides yazi.nvim -> yazi process interactions. This allows yazi.nvim to tell yazi what to do.
---@field private config YaziConfig
---@field private yazi_id string
local YaziProcessApi = {}
YaziProcessApi.__index = YaziProcessApi

---@param config YaziConfig
---@param yazi_id string
function YaziProcessApi.new(config, yazi_id)
  local self = setmetatable({}, YaziProcessApi)
  self.config = config
  self.yazi_id = yazi_id
  return self
end

--- Emit a command to the yazi process.
--- https://yazi-rs.github.io/docs/dds#ya-emit
---@param args string[]
---@return vim.SystemObj
function YaziProcessApi:emit_to_yazi(args)
  local Log = require("yazi.log")
  Log:debug(
    string.format(
      "emit_to_yazi: Using 'ya emit-to %s' with args: '%s'",
      self.yazi_id,
      vim.inspect(args)
    )
  )
  return vim.system(
    { "ya", "emit-to", self.yazi_id, unpack(args) },
    { timeout = 1000 },
    function(result)
      Log:debug(
        string.format(
          "emit_to_yazi: ya succeeded: 'ya emit-to %s' with args: '%s' and result '%s'",
          self.yazi_id,
          vim.inspect(args),
          vim.inspect(result)
        )
      )
    end
  )
end

--- Tell yazi to focus (hover on) the given path.
--- https://yazi-rs.github.io/docs/configuration/keymap#manager.reveal
---@param path string
---@return vim.SystemObj
function YaziProcessApi:reveal(path)
  return self:emit_to_yazi({ "reveal", "--str", path })
end

--- Tell yazi to open the currently selected file(s).
---@see https://yazi-rs.github.io/docs/configuration/keymap#manager.open
function YaziProcessApi:open()
  self:emit_to_yazi({ "open" })
end

return YaziProcessApi
