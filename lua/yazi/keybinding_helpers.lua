---@module "plenary.path"

local openers = require("yazi.openers")
local Log = require("yazi.log")
local utils = require("yazi.utils")

--- Hacky actions that can be used when yazi is open. They typically select the
--- current file and execute some useful operation on the selected file.
local YaziOpenerActions = {}

---@param config YaziConfig
---@param api YaziProcessApi
function YaziOpenerActions.open_file_in_vertical_split(config, api)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    api = api,
    on_file_opened = openers.open_file_in_vertical_split,
  })
end

---@param config YaziConfig
---@param api YaziProcessApi
function YaziOpenerActions.open_file_in_horizontal_split(config, api)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    api = api,
    on_file_opened = openers.open_file_in_horizontal_split,
  })
end

---@param config YaziConfig
---@param api YaziProcessApi
function YaziOpenerActions.open_file_in_tab(config, api)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    api = api,
    on_file_opened = openers.open_file_in_tab,
  })
end

--
--
--
--
---@class (exact) YaziOpenerActionsCallbacks
---@field api YaziProcessApi
---@field on_file_opened fun(chosen_file: string, config: YaziConfig, state: YaziClosedState):nil
---@field on_multiple_files_opened? fun(chosen_files: string[], config: YaziConfig, state: YaziClosedState):nil

-- This is a utility function that can be used in the set_keymappings_function
-- You can also use it in your own keymappings function
---@param config YaziConfig
---@param callbacks YaziOpenerActionsCallbacks
function YaziOpenerActions.select_current_file_and_close_yazi(config, callbacks)
  config.open_file_function = callbacks.on_file_opened

  if callbacks.on_multiple_files_opened == nil then
    callbacks.on_multiple_files_opened = function(chosen_files, cfg, state)
      for _, chosen_file in ipairs(chosen_files) do
        cfg.open_file_function(chosen_file, cfg, state)
      end
    end
  end

  config.hooks.yazi_opened_multiple_files = callbacks.on_multiple_files_opened

  if config.future_features.ya_emit_open then
    callbacks.api:open()
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<enter>", true, false, true),
      "n",
      true
    )
  end
end

---@param config YaziConfig
---@param context YaziActiveContext
function YaziOpenerActions.cycle_open_buffers(config, context)
  assert(context.input_path, "No input path found")
  assert(context.input_path.filename, "No input path filename found")

  local current_cycle_position = (
    context.cycled_file and context.cycled_file.path
  ) or context.input_path
  local visible_buffers = utils.get_visible_open_buffers()

  if #visible_buffers == 0 then
    Log:debug(
      string.format(
        'No visible buffers found for path: "%s"',
        context.input_path
      )
    )
    return
  end

  for i, buffer in ipairs(visible_buffers) do
    if
      buffer.renameable_buffer:matches_exactly(current_cycle_position.filename)
    then
      Log:debug(
        string.format(
          'Found buffer for path: "%s", will open the next buffer',
          context.input_path
        )
      )
      local other_buffers = vim.list_slice(visible_buffers, i + 1)
      other_buffers = vim.list_extend(other_buffers, visible_buffers, 1, i - 1)
      local next_buffer = vim.iter(other_buffers):find(function(b)
        return b.renameable_buffer.path.filename
          ~= current_cycle_position.filename
      end)

      if #visible_buffers == 1 then
        next_buffer = buffer
      end

      if not next_buffer then
        Log:debug(
          string.format(
            'Could not find next buffer for path: "%s".',
            context.input_path
          )
        )
        return
      end

      if config.future_features.ya_emit_reveal then
        local nextfile = next_buffer.renameable_buffer.path.filename

        -- make sure the type is a string, because plenary thinks it is `string|unknown`
        assert(type(nextfile) == "string", "Expected filename to be a string")
        context.api:reveal(nextfile)
        context.cycled_file = next_buffer.renameable_buffer
        return
      else
        local directory =
          vim.fn.fnamemodify(next_buffer.renameable_buffer.path.filename, ":h")
        assert(
          directory,
          string.format(
            'Found the next buffer, but could not find its base directory. The buffer: "%s", aborting.',
            next_buffer.renameable_buffer.path.filename
          )
        )

        context.api:cd(directory)
        context.cycled_file = next_buffer.renameable_buffer
        return
      end
    end
  end

  Log:debug(
    string.format(
      'Could not find cycle_open_buffers for path: "%s"',
      context.input_path
    )
  )
end

---@param config YaziConfig
---@param chosen_file string
---@return nil
function YaziOpenerActions.grep_in_directory(config, chosen_file)
  if config.integrations.grep_in_directory == nil then
    return
  end
  local last_directory = utils.dir_of(chosen_file).filename
  config.integrations.grep_in_directory(last_directory)
end

---@param config YaziConfig
---@param chosen_files string[]
function YaziOpenerActions.grep_in_selected_files(config, chosen_files)
  if config.integrations.grep_in_selected_files == nil then
    return
  end

  local plenary_path = require("plenary.path")
  local paths = {}
  for _, path in ipairs(chosen_files) do
    table.insert(paths, plenary_path:new(path))
  end

  config.integrations.grep_in_selected_files(paths)
end

---@param config YaziConfig
---@param chosen_file string
function YaziOpenerActions.replace_in_directory(config, chosen_file)
  if config.integrations.replace_in_directory == nil then
    return
  end

  local last_directory = utils.dir_of(chosen_file)
  -- search and replace in the directory
  local success, result_or_error =
    pcall(config.integrations.replace_in_directory, last_directory)

  if not success then
    local detail = vim.inspect({
      message = "yazi.nvim: error replacing with grug-far.nvim.",
      error = result_or_error,
    })
    vim.notify(detail, vim.log.levels.WARN)
    Log:debug(vim.inspect({ message = detail, error = result_or_error }))
  end
end

---@param config YaziConfig
---@param chosen_files string[]
function YaziOpenerActions.replace_in_selected_files(config, chosen_files)
  if config.integrations.replace_in_selected_files == nil then
    return
  end

  -- limit the replace operation to the selected files only
  local plenary_path = require("plenary.path")
  local paths = {}
  for _, path in ipairs(chosen_files) do
    table.insert(paths, plenary_path:new(path))
  end

  local success, result_or_error =
    pcall(config.integrations.replace_in_selected_files, paths)

  if not success then
    local detail = vim.inspect({
      message = "yazi.nvim: error replacing with grug-far.nvim.",
      error = result_or_error,
    })
    vim.notify(detail, vim.log.levels.WARN)
    Log:debug(vim.inspect({ message = detail, error = result_or_error }))
  end
end

---@param context YaziActiveContext
function YaziOpenerActions.change_working_directory(context)
  local last_directory = context.ya_process.cwd
  if not last_directory then
    assert(
      context.input_path,
      "No input_path found. Expected yazi to be started with an input_path"
    )
    if context.input_path:is_file() then
      last_directory = context.input_path:parent().filename
    else
      last_directory = context.input_path.filename
    end
  end

  if last_directory ~= vim.fn.getcwd() then
    vim.notify('cwd changed to "' .. last_directory .. '"')
    vim.cmd({ cmd = "cd", args = { last_directory } })
  end
end

return YaziOpenerActions
