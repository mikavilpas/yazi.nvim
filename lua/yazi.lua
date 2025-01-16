---@module "plenary"

local configModule = require("yazi.config")

local M = {}

M.version = "7.1.0" -- x-release-please-version

-- The last known state of yazi when it was closed
---@type YaziPreviousState
M.previous_state = {}

---@param config? YaziConfig?
---@param input_path? string
function M.yazi(config, input_path)
  local utils = require("yazi.utils")
  local YaziProcess = require("yazi.process.yazi_process")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  if utils.is_yazi_available() ~= true then
    print("Please install yazi. Check the documentation for more information")
    return
  end

  config =
    vim.tbl_deep_extend("force", configModule.default(), M.config, config or {})

  local Log = require("yazi.log")
  Log.level = config.log_level

  if utils.is_ya_available() ~= true then
    print(
      "Please install ya (the yazi command line utility). Check the documentation for more information"
    )
    return
  end

  local paths = utils.selected_file_paths(input_path)
  local path = paths[1]

  local prev_win = vim.api.nvim_get_current_win()
  local prev_buf = vim.api.nvim_get_current_buf()

  config.chosen_file_path = config.chosen_file_path or vim.fn.tempname()

  local win = require("yazi.window").YaziFloatingWindow.new(config)
  win:open_and_display()

  local yazi_process = YaziProcess:start(
    config,
    paths,
    function(exit_code, selected_files, events, hovered_url, last_directory)
      if exit_code ~= 0 then
        print(
          "yazi.nvim: had trouble opening yazi. Run ':checkhealth yazi' for more information."
        )
        Log:debug(
          string.format("yazi.nvim: had trouble opening yazi: %s", exit_code)
        )
        return
      end

      Log:debug(
        string.format(
          "yazi process exited successfully with code: %s, selected_files %s, and events %s",
          exit_code,
          vim.inspect(selected_files),
          vim.inspect(events)
        )
      )

      yazi_event_handling.process_events_emitted_from_yazi(events)

      if last_directory == nil then
        if path:is_file() then
          last_directory = path:parent()
        else
          last_directory = path
        end
      end

      Log:debug(
        string.format("Resolved the last_directory to %s", last_directory)
      )

      utils.on_yazi_exited(prev_win, prev_buf, win, config, selected_files, {
        last_directory = last_directory,
      })

      if hovered_url then
        -- currently we can't reliably get the hovered_url from ya due to
        -- https://github.com/sxyazi/yazi/issues/1314 so let's try to at least
        -- not corrupt the last working hovered state
        M.previous_state.last_hovered = hovered_url
      end
    end
  )

  config.hooks.yazi_opened(path.filename, win.content_buffer, config)

  ---@type YaziActiveContext
  local context = {
    api = yazi_process.api,
    input_path = path,
    ya_process = yazi_process.ya_process,
  }

  local yazi_buffer = win.content_buffer
  if config.set_keymappings_function ~= nil then
    config.set_keymappings_function(yazi_buffer, config, context)
  end

  if config.keymaps ~= false then
    require("yazi.config").set_keymappings(yazi_buffer, config, context)
  end

  win.on_resized = function(event)
    vim.fn.jobresize(
      yazi_process.yazi_job_id,
      event.win_width,
      event.win_height
    )
  end

  vim.schedule(function()
    vim.cmd("startinsert")
  end)
end

-- Open yazi, continuing from the previously hovered file. If no previous file
-- was hovered, open yazi with the default path.
---@param config? YaziConfig?
function M.toggle(config)
  local path = M.previous_state and M.previous_state.last_hovered or nil

  local Log = require("yazi.log")
  if path == nil then
    Log:debug("No previous file hovered, opening yazi with default path")
  else
    Log:debug(
      string.format("Opening yazi with previous file hovered: %s", path)
    )
  end
  M.yazi(config, path)
end

M.config = configModule.default()

---@param opts YaziConfig?
function M.setup(opts)
  M.config =
    vim.tbl_deep_extend("force", configModule.default(), M.config, opts or {})

  local Log = require("yazi.log")
  Log.level = M.config.log_level

  pcall(function()
    require("yazi.lsp.embedded-lsp-file-operations.lsp-file-operations").setup()
  end)

  local yazi_augroup = vim.api.nvim_create_augroup("yazi", { clear = true })

  if M.config.open_for_directories == true then
    Log:debug("Hijacking netrw to open yazi for directories")
    require("yazi.hijack_netrw").hijack_netrw(yazi_augroup)
  end
end

return M
