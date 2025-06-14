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

  callbacks.api:open()
end

---@param visible_buffer? YaziVisibleBuffer
local function show_visible_buffer(visible_buffer)
  if not visible_buffer then
    return "nil"
  end
  local renameable_buffer = visible_buffer.renameable_buffer
  return renameable_buffer.path:make_relative(vim.uv.cwd())
end

---@param _config YaziConfig
---@param context YaziActiveContext
---@diagnostic disable-next-line: unused-local
function YaziOpenerActions.cycle_open_buffers(_config, context)
  assert(context.input_path, "No input path found")
  assert(context.input_path.filename, "No input path filename found")

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

  Log:debug(
    string.format(
      "Looking at visible_buffers: %s",
      vim.inspect(vim.tbl_map(show_visible_buffer, visible_buffers))
    )
  )

  ---@type YaziVisibleBuffer | nil
  local next_buffer = nil

  -- find out what the currently highlighted buffer is, and what is the next
  -- buffer to be highlighted
  local current_cycle_position = (
    context.cycled_file and context.cycled_file.path
  )
  if not current_cycle_position and context.input_path:is_dir() then
    Log:debug(
      string.format(
        'No current cycle position found for path: "%s" (%s), so will use the first buffer "%s".',
        context.input_path,
        vim.inspect(current_cycle_position),
        show_visible_buffer(visible_buffers[1])
      )
    )

    next_buffer = visible_buffers[1]
  elseif #visible_buffers == 1 then
    Log:debug(
      string.format(
        'Only one visible buffer found for path: "%s" (current_cycle_position %s), so will use the first buffer "%s".',
        context.input_path,
        vim.inspect(current_cycle_position),
        show_visible_buffer(visible_buffers[1])
      )
    )
    next_buffer = visible_buffers[1]
  else
    local current = (
      current_cycle_position and current_cycle_position:absolute()
    ) or context.input_path:absolute()
    assert(current, "No current cycle position found")

    for i, buffer in ipairs(visible_buffers) do
      if buffer.renameable_buffer:matches_exactly(current) then
        local other_buffers = vim.list_slice(visible_buffers, i + 1)
        other_buffers =
          vim.list_extend(other_buffers, visible_buffers, 1, i - 1)
        next_buffer = vim.iter(other_buffers):find(function(b)
          ---@cast b YaziVisibleBuffer
          local this = b.renameable_buffer.path:absolute()
          return this ~= current
        end)

        Log:debug(
          string.format(
            "Current cycled buffer: %s (index %s), next buffer: %s",
            show_visible_buffer(buffer),
            i,
            show_visible_buffer(next_buffer)
          )
        )
        break
      end
    end
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

  local nextfile = next_buffer.renameable_buffer.path.filename
  if not nextfile then
    Log:debug(
      string.format(
        'Could not find cycle_open_buffers for path: "%s"',
        context.input_path
      )
    )
    return
  end

  Log:debug(
    string.format(
      'Found buffer for path: "%s", will reveal the next buffer: "%s"',
      context.input_path,
      nextfile
    )
  )

  -- make sure the type is a string, because plenary thinks it is `string|unknown`
  context.api:reveal(next_buffer.renameable_buffer.path:absolute())
  context.cycled_file = next_buffer.renameable_buffer
end

---@param config YaziConfig
---@param chosen_file string
---@return nil
function YaziOpenerActions.grep_in_directory(config, chosen_file)
  if config.integrations.grep_in_directory == nil then
    -- the user has opted out of this feature for some reason. Do nothing.
    return
  end
  local cwd = vim.uv.cwd()
  local last_directory = utils.dir_of(chosen_file):make_relative(cwd)

  if config.integrations.grep_in_directory == "telescope" then
    require("telescope.builtin").live_grep({
      search = "",
      prompt_title = "Grep in " .. last_directory,
      cwd = last_directory,
    })
  elseif config.integrations.grep_in_directory == "fzf-lua" then
    require("fzf-lua").live_grep({
      search_paths = { last_directory },
    })
  elseif config.integrations.grep_in_directory == "snacks.picker" then
    vim.defer_fn(function()
      -- HACK something seems to exit insert mode when the picker is shown.
      -- Wait a bit to hack around this.
      require("snacks.picker").grep({
        title = "Grep in " .. last_directory,
        dirs = { last_directory },
        on_show = function()
          vim.cmd("startinsert")
        end,
      })
    end, 50)
  else
    -- the user has a custom implementation. Call it.
    config.integrations.grep_in_directory(last_directory)
  end
end

---@param config YaziConfig
---@param chosen_files string[]
function YaziOpenerActions.grep_in_selected_files(config, chosen_files)
  if config.integrations.grep_in_selected_files == nil then
    -- the user has opted out of this feature for some reason. Do nothing.
    return
  end

  local plenary_path = require("plenary.path")

  ---@type Path[]
  local paths = {}
  for _, path in ipairs(chosen_files) do
    table.insert(paths, plenary_path:new(path))
  end

  -- pickers typically work with file paths relative to the cwd
  ---@type string[]
  local files_relative = {}
  for _, path in ipairs(paths) do
    files_relative[#files_relative + 1] =
      path:make_relative(vim.uv.cwd()):gsub(" ", "\\ ")
  end

  if config.integrations.grep_in_selected_files == "telescope" then
    require("telescope.builtin").live_grep({
      search = "",
      prompt_title = string.format("Grep in %d paths", #files_relative),
      search_dirs = files_relative,
    })
  elseif config.integrations.grep_in_selected_files == "fzf-lua" then
    require("fzf-lua").live_grep({ search_paths = files_relative })
  elseif config.integrations.grep_in_selected_files == "snacks.picker" then
    vim.defer_fn(function()
      -- HACK something seems to exit insert mode when the picker is shown.
      -- Wait a bit to hack around this.
      require("snacks.picker").grep({
        title = string.format("Grep in %d paths", #files_relative),
        dirs = files_relative,
      })
    end, 50)
  else
    -- the user has a custom implementation. Call it.
    config.integrations.grep_in_selected_files(paths, files_relative)
  end
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
      message = "error replacing with grug-far.nvim.",
      error = result_or_error,
    })
    vim.notify(detail, vim.log.levels.WARN, { title = "yazi.nvim" })
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
      message = "error replacing with grug-far.nvim.",
      error = result_or_error,
    })
    vim.notify(detail, vim.log.levels.WARN, { title = "yazi.nvim" })
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

---@param config YaziConfig
---@param context YaziActiveContext
function YaziOpenerActions.open_and_pick_window(config, context)
  YaziOpenerActions.select_current_file_and_close_yazi(config, {
    api = context.api,
    on_file_opened = function(chosen_file, _, _)
      if config.integrations.pick_window_implementation ~= "snacks.picker" then
        require("yazi.log"):debug(
          string.format(
            "snacks_picker integration is unexpected (%s). Cannot pick window.",
            vim.inspect(config.integrations.pick_window_implementation)
          )
        )
        return
      end

      local snacks_picker_util = require("snacks.picker.util")
      local picked_win_id = snacks_picker_util.pick_win()
      if picked_win_id and vim.api.nvim_win_is_valid(picked_win_id) then
        vim.api.nvim_set_current_win(picked_win_id)
        require("yazi.openers").open_file(chosen_file)
      end
    end,
  })
end

return YaziOpenerActions
