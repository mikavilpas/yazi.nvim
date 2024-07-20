---@class YaziProcessApi
---@field private config YaziConfig
---@field private yazi_id string
local YaziProcessApi = {}

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
    -- ya pub --str "/" dds-cd 1760127405452166
    assert(path, 'path is required')
    vim.system(
      { 'ya', 'pub', '--str', path, 'dds-cd', self.yazi_id },
      { timeout = 1000 }
    )
  end
end

return YaziProcessApi
