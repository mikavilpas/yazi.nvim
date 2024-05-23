local openers = require('yazi.openers')

--- Hacky actions that can be used when yazi is open. They typically select the
--- current file and execute some useful operation on the selected file.
---@class YaziOpenerActions
local YaziOpenerActions = {}

---@param config YaziConfig
function YaziOpenerActions.open_file_in_vertical_split(config)
  config.open_file_function = openers.open_file_in_vertical_split
  config.hooks.yazi_opened_multiple_files = function(
    chosen_files,
    _config,
    state
  )
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config, state)
    end
  end
  YaziOpenerActions.select_current_file_and_close_yazi()
end

---@param config YaziConfig
function YaziOpenerActions.open_file_in_horizontal_split(config)
  config.open_file_function = openers.open_file_in_horizontal_split
  config.hooks.yazi_opened_multiple_files = function(chosen_files)
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config)
    end
  end
  YaziOpenerActions.select_current_file_and_close_yazi()
end

---@param config YaziConfig
function YaziOpenerActions.open_file_in_tab(config)
  config.open_file_function = openers.open_file_in_tab
  config.hooks.yazi_opened_multiple_files = function(chosen_files)
    for _, chosen_file in ipairs(chosen_files) do
      config.open_file_function(chosen_file, config)
    end
  end
  YaziOpenerActions.select_current_file_and_close_yazi()
end

-- This is a utility function that can be used in the set_keymappings_function
-- You can also use it in your own keymappings function
function YaziOpenerActions.select_current_file_and_close_yazi()
  -- select the current file in yazi and close it (enter is the default
  -- keybinding for selecting a file)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<enter>', true, false, true),
    'n',
    true
  )
end

return YaziOpenerActions
