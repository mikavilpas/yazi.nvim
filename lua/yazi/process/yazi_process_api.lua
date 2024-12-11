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

---@param path string
function YaziProcessApi:cd(path)
  vim.system(
    { "ya", "pub-to", self.yazi_id, "--str", path, "dds-cd" },
    { timeout = 1000 }
  )
end

--- Tell yazi to focus (hover on) the given path.
---@see https://yazi-rs.github.io/docs/configuration/keymap#manager.reveal
---@param path string
function YaziProcessApi:reveal(path)
  vim.system(
    { "ya", "emit-to", self.yazi_id, "reveal", "--str", path },
    { timeout = 1000 }
  )
end

--- Tell yazi to open the currently selected file(s).
---@see https://yazi-rs.github.io/docs/configuration/keymap#manager.open
function YaziProcessApi:open()
  vim.system({ "ya", "emit-to", self.yazi_id, "open" }, { timeout = 1000 })
end

return YaziProcessApi
