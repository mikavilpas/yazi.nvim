local openers = require('yazi.openers')

--- Hacky actions that can be used when yazi is open. They typically select the
--- current file and execute some useful operation on the selected file.
---@class YaziOpenerActions
local YaziOpenerActions = {}

---@param config YaziConfig
function YaziOpenerActions.open_file_in_vertical_split(config)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    on_file_opened = openers.open_file_in_vertical_split,
  })
end

---@param config YaziConfig
function YaziOpenerActions.open_file_in_horizontal_split(config)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    on_file_opened = openers.open_file_in_horizontal_split,
  })
end

---@param config YaziConfig
function YaziOpenerActions.open_file_in_tab(config)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    on_file_opened = openers.open_file_in_tab,
  })
end

--
--
--
--
---@class YaziOpenerActionsCallbacks
---@field on_file_opened fun(chosen_file: string, config: YaziConfig, state: YaziClosedState):nil
---@field on_multiple_files_opened? fun(chosen_files: string[], config: YaziConfig, state: YaziClosedState):nil

-- This is a utility function that can be used in the set_keymappings_function
-- You can also use it in your own keymappings function
---@param config YaziConfig
---@param callbacks YaziOpenerActionsCallbacks
function YaziOpenerActions.select_current_file_and_close_yazi(config, callbacks)
  config.open_file_function = callbacks.on_file_opened

  if callbacks.on_multiple_files_opened == nil then
    ---@diagnostic disable-next-line: redefined-local
    callbacks.on_multiple_files_opened = function(chosen_files, config, state)
      for _, chosen_file in ipairs(chosen_files) do
        config.open_file_function(chosen_file, config, state)
      end
    end
  end

  config.hooks.yazi_opened_multiple_files = callbacks.on_multiple_files_opened

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<enter>', true, false, true),
    'n',
    true
  )
end

return YaziOpenerActions
