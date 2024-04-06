---@class YaziConfig
---@field public open_for_directories boolean

---@class YaziRenameEvent
---@field public type "rename"
---@field public timestamp string
---@field public id string
---@field public data YaziEventDataRename

---@class YaziEventDataRename
---@field public from string
---@field public to string
