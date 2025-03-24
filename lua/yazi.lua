---@module "plenary"

local configModule = require("yazi.config")

local M = {}

M.version = "10.0.0" -- x-release-please-version

-- The last known state of yazi when it was closed
---@type YaziPreviousState
M.previous_state = {}

---@alias yazi.Arguments {reveal_path: string}

---@param config? YaziConfig | {}
---@param input_path? string
---@param args? yazi.Arguments
function M.yazi(config, input_path, args)
  local utils = require("yazi.utils")
  local YaziProcess = require("yazi.process.yazi_process")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  if utils.is_yazi_available() ~= true then
    print(
      "Please install yazi and make sure it is on your `vim.env.PATH`. Check the documentation for more information"
    )
    return
  end

  config =
    vim.tbl_deep_extend("force", configModule.default(), M.config, config or {})

  local Log = require("yazi.log")
  Log.level = config.log_level

  if utils.is_ya_available() ~= true then
    print(
      "Please install ya (the yazi command line utility) and make sure it is on your `vim.env.PATH`. Check the documentation for more information"
    )
    return
  end

  local paths = utils.selected_file_paths(input_path)
  local path = paths[1]

  local prev_win = vim.api.nvim_get_current_win()

  config.chosen_file_path = config.chosen_file_path or vim.fn.tempname()

  local win = require("yazi.window").YaziFloatingWindow.new(config)
  win:open_and_display()

  local yazi_process = YaziProcess:start(config, paths, {
    on_maybe_started = function(yazi)
      if not (args and args.reveal_path) then
        return
      end

      local retries_remaining = 5
      local function try()
        local success = pcall(function()
          local result = yazi.api:reveal(args.reveal_path)
          local completed = result:wait(500)
          assert(completed.code == 0)
          Log:debug(
            string.format(
              "Revealed path '%s' successfully after retries_remaining: %s",
              args.reveal_path,
              retries_remaining
            )
          )
        end)
        if not success then
          retries_remaining = retries_remaining - 1
          if retries_remaining == 0 then
            Log:debug(
              string.format(
                "Failed to reveal path '%s' after 5 retries",
                args.reveal_path
              )
            )
            return
          end

          Log:debug(
            string.format(
              "Failed to reveal path '%s', retrying after 50ms. retries_remaining: %s",
              args.reveal_path,
              retries_remaining
            )
          )
          vim.defer_fn(try, 50)
        end
      end

      try()
    end,
    on_exit = function(
      exit_code,
      selected_files,
      events,
      hovered_url,
      last_directory
    )
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

      -- this is the legacy implementation used when
      -- `future_features.process_events_live = false`. When that is used,
      -- events should be processed in ya_process.lua and should not be
      -- processed a second time here.
      assert(#events == 0 or not config.future_features.process_events_live)

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

      utils.on_yazi_exited(prev_win, win, config, selected_files, {
        last_directory = last_directory,
      })

      if hovered_url then
        -- currently we can't reliably get the hovered_url from ya due to
        -- https://github.com/sxyazi/yazi/issues/1314 so let's try to at least
        -- not corrupt the last working hovered state
        M.previous_state.last_hovered = hovered_url
      end
    end,
  })

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
---@param config? YaziConfig | {}
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
  if path then
    M.yazi(config, path, { reveal_path = path })
  else
    M.yazi(config, path)
  end
end

M.config = configModule.default()

---@param opts YaziConfig | {}
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
