-- TODO all config properties are optional when given, but mandatory inside the plugin

---@module "plenary.path"

---@alias YaziFloatingWindowScaling { height: number, width: number }

---@class (exact) YaziConfig
---@field public open_for_directories? boolean
---@field public chosen_file_path? string "the path to a temporary file that will be created by yazi to store the chosen file path"
---@field public open_multiple_tabs? boolean "open multiple open files in yazi tabs when opening yazi"
---@field public enable_mouse_support? boolean
---@field public open_file_function? fun(chosen_file: string, config: YaziConfig, state: YaziClosedState): nil "a function that will be called when a file is chosen in yazi"
---@field public keymaps? YaziKeymaps | false # The keymaps that are available when yazi is open and focused. Set to `false` to disable all default keymaps.
---@field public set_keymappings_function? fun(buffer: integer, config: YaziConfig, context: YaziActiveContext): nil # Can be used to create new, custom keybindings. In most cases it's recommended to use `keymaps` to customize the keybindings that come with yazi.nvim
---@field public hooks? YaziConfigHooks
---@field public highlight_groups? YaziConfigHighlightGroups
---@field public integrations? YaziConfigIntegrations
---@field public floating_window_scaling_factor? number | YaziFloatingWindowScaling "the scaling factor for the floating window. 1 means 100%, 0.9 means 90%, etc."
---@field public yazi_floating_window_winblend? number "the transparency of the yazi floating window (0-100). See :h winblend"
---@field public yazi_floating_window_border? any "the type of border to use. See nvim_open_win() for the values your neovim version supports"
---@field public log_level? yazi.LogLevel
---@field public clipboard_register? string the register to use for copying. Defaults to "*", the system clipboard
---@field public highlight_hovered_buffers_in_same_directory? boolean "highlight buffers in the same directory as the hovered buffer"

---@alias YaziKeymap string | false # `string` is a keybinding such as "<c-tab>", false means the keybinding is disabled

---@class YaziKeymaps # The keybindings that are set by yazi, and can be overridden by the user. Will be set to a default value if not given explicitly
---@field show_help? YaziKeymap # Show a help menu with all the keybindings
---@field open_file_in_vertical_split? YaziKeymap # When a file is hovered, open it in a vertical split
---@field open_file_in_horizontal_split? YaziKeymap # When a file is hovered, open it in a horizontal split
---@field open_file_in_tab? YaziKeymap # When a file is hovered, open it in a new tab
---@field grep_in_directory? YaziKeymap # Close yazi and open a grep (default: telescope) narrowed to the directory yazi is in
---@field replace_in_directory? YaziKeymap # Close yazi and open a replacer (default: grug-far.nvim) narrowed to the directory yazi is in
---@field cycle_open_buffers? YaziKeymap # When Neovim has multiple splits open and visible, make yazi jump to the directory of the next one
---@field copy_relative_path_to_selected_files? YaziKeymap # Copy the relative paths of the selected files to the clipboard
---@field send_to_quickfix_list? YaziKeymap # Send the selected files to the quickfix list for later processing

---@class (exact) YaziActiveContext # context state for a single yazi session
---@field api YaziProcessApi
---@field input_path Path the path that is first selected by yazi when it's opened
---@field cycled_file? RenameableBuffer the last file that was cycled to with e.g. the <tab> key

---@class (exact) YaziConfigHooks
---@field public yazi_opened fun(preselected_path: string | nil, buffer: integer, config: YaziConfig):nil
---@field public yazi_closed_successfully fun(chosen_file: string | nil, config: YaziConfig, state: YaziClosedState): nil
---@field public yazi_opened_multiple_files fun(chosen_files: string[], config: YaziConfig, state: YaziClosedState): nil

---@class (exact) YaziConfigIntegrations # Defines settings for integrations with other plugins and tools
---@field public grep_in_directory? fun(directory: string): nil "a function that will be called when the user wants to grep in a directory"
---@field public grep_in_selected_files? fun(selected_files: Path[]): nil"called to grep on files that were selected in yazi"
---@field public replace_in_directory? fun(directory: Path, selected_files?: Path[]): nil "called to start a replacement operation on some directory; by default uses grug-far.nvim"
---@field public replace_in_selected_files? fun(selected_files?: Path[]): nil "called to start a replacement operation on files that were selected in yazi; by default uses grug-far.nvim"
---@field public resolve_relative_path_application? string "the application that will be used to resolve relative paths. By default, this is GNU `realpath` on Linux and `grealpath` on macOS"

---@class (exact) YaziConfigHighlightGroups # Defines the highlight groups that will be used in yazi
---@field public hovered_buffer? vim.api.keyset.highlight # the color of a buffer that is hovered over in yazi
---@field public hovered_buffer_in_same_directory? vim.api.keyset.highlight # the color of a buffer that is in the same directory as the hovered buffer

---@alias YaziEvent YaziRenameEvent | YaziMoveEvent | YaziDeleteEvent | YaziTrashEvent | YaziChangeDirectoryEvent | YaziHoverEvent | YaziBulkEvent

---@class (exact) YaziPreviousState # describes the previous state of yazi when it was closed; the last known state
---@field public last_hovered? string

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
---@field public yazi_id string
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
