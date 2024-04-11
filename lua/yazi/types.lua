---@class YaziConfig
---@field public open_for_directories? boolean
---@field public chosen_file_path? string "the path to a temporary file that will be created by yazi to store the chosen file path"
---@field public events_file_path? string "the path to a temporary file that will be created by yazi to store events"
---@field public open_file_function? fun(chosen_file: string): nil "a function that will be called when a file is chosen in yazi"
---@field public hooks? YaziConfigHooks
---@field public floating_window_scaling_factor? float "the scaling factor for the floating window. 1 means 100%, 0.9 means 90%, etc."
---@field public yazi_floating_window_winblend? float "the winblend value for the floating window. See :h winblend"

---@class YaziConfigHooks
---@field public yazi_opened? fun(preselected_path: string | nil): nil
---@field public yazi_closed_successfully? fun(chosen_file: string | nil): nil

---@alias YaziEvent YaziRenameEvent | YaziMoveEvent | YaziDeleteEvent | YaziTrashEvent

---@class YaziRenameEvent
---@field public type "rename"
---@field public timestamp string
---@field public id string
---@field public data YaziEventDataRenameOrMove

---@class YaziMoveEvent
---@field public type "move"
---@field public timestamp string
---@field public id string
---@field public data {items: YaziEventDataRenameOrMove[]}

---@class YaziEventDataRenameOrMove
---@field public from string
---@field public to string

---@class YaziDeleteEvent
---@field public type "delete"
---@field public timestamp string
---@field public id string
---@field public data {urls: string[]}

---@class YaziTrashEvent
---@field public type "trash"
---@field public timestamp string
---@field public id string
---@field public data {urls: string[]}
