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

---@class YaziBufferRenameInstruction
---@field buffer integer the existing buffer number that needs renaming
---@field to string the new file name that the buffer should point to
