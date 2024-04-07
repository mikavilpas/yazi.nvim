---@class YaziConfig
---@field public open_for_directories? boolean
---@field public chosen_file_path? string "the path to a temporary file that will be created by yazi to store the chosen file path"
---@field public events_file_path? string "the path to a temporary file that will be created by yazi to store events"
---@field public open_file_function? fun(chosen_file: string): nil "a function that will be called when a file is chosen in yazi"
---@field public hooks? YaziConfigHooks

---@class YaziConfigHooks
---@field public yazi_closed_successfully? fun(chosen_file: string | nil): nil

---@class YaziRenameEvent
---@field public type "rename"
---@field public timestamp string
---@field public id string
---@field public data YaziEventDataRename

---@class YaziEventDataRename
---@field public from string
---@field public to string
