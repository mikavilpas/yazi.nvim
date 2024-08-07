---@class YaziProcessApi # Provides yazi.nvim -> yazi process interactions
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
  if
    self.config.use_ya_for_events_reading == true
    and self.config.use_yazi_client_id_flag == true
  then
    assert(path, "path is required")
    vim.system(
      { "ya", "pub-to", self.yazi_id, "--str", path, "dds-cd" },
      { timeout = 1000 }
    )
  end
end

return YaziProcessApi
