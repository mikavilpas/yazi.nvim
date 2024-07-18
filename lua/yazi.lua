---@module "plenary"

local window = require('yazi.window')
local utils = require('yazi.utils')
local configModule = require('yazi.config')
local event_handling = require('yazi.event_handling')
local Log = require('yazi.log')
local YaziProcess = require('yazi.yazi_process')

local M = {}

-- gets updated automatically by release-please
M.version = '2.2.1' -- x-release-please-version

---@param config? YaziConfig?
---@param input_path? string
---@diagnostic disable-next-line: redefined-local
function M.yazi(config, input_path)
  if utils.is_yazi_available() ~= true then
    print('Please install yazi. Check the documentation for more information')
    return
  end

  config =
    vim.tbl_deep_extend('force', configModule.default(), M.config, config or {})

  if
    config.use_ya_for_events_reading == true
    and utils.is_ya_available() ~= true
  then
    print(
      'Please install ya (the yazi command line utility). Check the documentation for more information'
    )
    return
  end

  local path = utils.selected_file_path(input_path)

  local prev_win = vim.api.nvim_get_current_win()
  local prev_buf = vim.api.nvim_get_current_buf()

  config.chosen_file_path = config.chosen_file_path or vim.fn.tempname()
  config.events_file_path = config.events_file_path or vim.fn.tempname()

  local win = window.YaziFloatingWindow.new(config)
  win:open_and_display()

  local yazi_process = YaziProcess:start(
    config,
    path,
    function(exit_code, selected_files, events)
      if exit_code ~= 0 then
        print(
          "yazi.nvim: had trouble opening yazi. Run ':checkhealth yazi' for more information."
        )
        Log:debug(
          string.format('yazi.nvim: had trouble opening yazi: %s', exit_code)
        )
        return
      end

      Log:debug(
        string.format(
          'yazi process exited successfully with code: %s, selected_files %s, and events %s',
          exit_code,
          vim.inspect(selected_files),
          vim.inspect(events)
        )
      )

      local event_info = event_handling.process_events_emitted_from_yazi(events)

      local last_directory = event_info.last_directory
      if last_directory == nil then
        if path:is_file() then
          last_directory = path:parent()
        else
          last_directory = path
        end
      end
      utils.on_yazi_exited(prev_win, prev_buf, win, config, selected_files, {
        last_directory = event_info.last_directory or path:parent(),
      })
    end
  )

  config.hooks.yazi_opened(path.filename, win.content_buffer, config)
  config.set_keymappings_function(win.content_buffer, config)

  win.on_resized = function(event)
    vim.fn.jobresize(
      yazi_process.yazi_job_id,
      event.win_width,
      event.win_height
    )
  end

  vim.schedule(function()
    vim.cmd('startinsert')
  end)
end

M.config = configModule.default()

---@param opts YaziConfig?
function M.setup(opts)
  M.config =
    vim.tbl_deep_extend('force', configModule.default(), M.config, opts or {})

  Log.level = M.config.log_level

  local yazi_augroup = vim.api.nvim_create_augroup('yazi', { clear = true })

  if M.config.open_for_directories == true then
    ---@param file string
    ---@param bufnr number
    local function open_yazi_in_directory(file, bufnr)
      if vim.fn.isdirectory(file) == 1 then
        -- A buffer was opened for a directory.
        -- Remove the buffer as we want to show yazi instead
        vim.api.nvim_buf_delete(bufnr, { force = true })
        M.yazi(M.config, file)

        -- HACK: for some reason, the cursor is not in insert mode when opening
        -- yazi, so just simulate pressing "i" to enter insert mode :)
        -- It did nothing when when I tried using vim.cmd('startinsert') or vim.cmd('normal! i')
        vim.api.nvim_feedkeys('i', 'n', false)
      end
    end

    -- disable netrw, the built-in file explorer
    vim.cmd('silent! autocmd! FileExplorer *')

    -- executed before starting to edit a new buffer.
    vim.api.nvim_create_autocmd('BufAdd', {
      pattern = '*',
      ---@param ev yazi.AutoCmdEvent
      callback = function(ev)
        open_yazi_in_directory(ev.file, ev.buf)
      end,
      group = yazi_augroup,
    })

    -- When opening neovim with "nvim ." or "nvim <directory>", the current
    -- buffer is already open at this point. If we have already opened a
    -- directory, display yazi instead.
    open_yazi_in_directory(
      vim.b.netrw_curdir or vim.fn.expand('%:p'),
      vim.api.nvim_get_current_buf()
    )
  end
end

return M
