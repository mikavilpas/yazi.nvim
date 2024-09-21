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
  assert(path, "path is required")
  vim.system(
    { "ya", "pub-to", self.yazi_id, "--str", path, "dds-cd" },
    { timeout = 1000 }
  )
end

return YaziProcessApi
