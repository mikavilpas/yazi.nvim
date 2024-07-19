-- TODO all config properties are optional when given, but mandatory inside the plugin

---@module "plenary.path"

---@class (exact) YaziConfig
---@field public open_for_directories? boolean
---@field public chosen_file_path? string "the path to a temporary file that will be created by yazi to store the chosen file path"
---@field public events_file_path? string "the path to a temporary file that will be created by yazi to store events. A random path will be used by default"
---@field public use_ya_for_events_reading? boolean "use `ya`, the yazi command line application to read events from the yazi process. Right now this is opt-in, but will be the default in the future"
---@field public use_yazi_client_id_flag? boolean "use the `--client-id` flag with yazi, allowing communication with that specific instance as opposed to all yazis on the system"
---@field public enable_mouse_support? boolean
---@field public open_file_function? fun(chosen_file: string, config: YaziConfig, state: YaziClosedState): nil "a function that will be called when a file is chosen in yazi"
---@field public set_keymappings_function? fun(buffer: integer, config: YaziConfig): nil "the function that will set the keymappings for the yazi floating window. It will be called after the floating window is created."
---@field public hooks? YaziConfigHooks
---@field public highlight_groups? YaziConfigHighlightGroups
---@field public integrations? YaziConfigIntegrations
---@field public floating_window_scaling_factor? number "the scaling factor for the floating window. 1 means 100%, 0.9 means 90%, etc."
---@field public yazi_floating_window_winblend? number "the transparency of the yazi floating window (0-100). See :h winblend"
---@field public yazi_floating_window_border? any "the type of border to use. See nvim_open_win() for the values your neovim version supports"
---@field public log_level? yazi.LogLevel

---@class (exact) YaziConfigHooks
---@field public yazi_opened fun(preselected_path: string | nil, buffer: integer, config: YaziConfig):nil
---@field public yazi_closed_successfully fun(chosen_file: string | nil, config: YaziConfig, state: YaziClosedState): nil
---@field public yazi_opened_multiple_files fun(chosen_files: string[], config: YaziConfig, state: YaziClosedState): nil

---@class (exact) YaziConfigIntegrations # Defines settings for integrations with other plugins and tools
---@field public grep_in_directory? fun(directory: string): nil "a function that will be called when the user wants to grep in a directory"

---@class (exact) YaziConfigHighlightGroups # Defines the highlight groups that will be used in yazi
---@field public hovered_buffer? vim.api.keyset.highlight # the color of a buffer that is hovered over in yazi

---@alias YaziEvent YaziRenameEvent | YaziMoveEvent | YaziDeleteEvent | YaziTrashEvent | YaziChangeDirectoryEvent | YaziHoverEvent | YaziBulkEvent

---@class (exact) YaziClosedState # describes the state of yazi when it was closed; the last known state
---@field public last_directory Path # the last directory that yazi was in before it was closed

---@class (exact) YaziRenameEvent
---@field public type "rename"
---@field public timestamp string
---@field public id string
---@field public data YaziEventDataRenameOrMove

---@class (exact) YaziMoveEvent
---@field public type "move"
---@field public timestamp string
---@field public id string
---@field public data {items: YaziEventDataRenameOrMove[]}

---@class (exact) YaziEventDataRenameOrMove
---@field public from string
---@field public to string

---@class (exact) YaziDeleteEvent
---@field public type "delete"
---@field public timestamp string
---@field public id string
---@field public data {urls: string[]}

---@class (exact) YaziTrashEvent
---@field public type "trash"
---@field public timestamp string
---@field public id string
---@field public data {urls: string[]}

---@class (exact) YaziChangeDirectoryEvent
---@field public type "cd"
---@field public timestamp string
---@field public id string
---@field public url string

---@class (exact) YaziHoverEvent "The event that is emitted when the user hovers over a file in yazi"
---@field public type "hover"
---@field public url string

---@class (exact) YaziBulkEvent "Like `rename` and `move` but for bulk renaming"
---@field public type "bulk"
---@field public changes table<string, string> # a table of old paths to new paths

---@class (exact) yazi.AutoCmdEvent # the nvim_create_autocmd() event object copied from the nvim help docs
---@field public id number
---@field public event string
---@field public group number | nil
---@field public match string
---@field public buf number
---@field public file string
---@field public data any
