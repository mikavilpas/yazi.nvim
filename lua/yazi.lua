local window = require('yazi.window')
local utils = require('yazi.utils')
local vimfn = require('yazi.vimfn')
local configModule = require('yazi.config')
local event_handling = require('yazi.event_handling')

local M = {}

M.yazi_loaded = false

---@param config? YaziConfig?
---@param path? string
---@diagnostic disable-next-line: redefined-local
function M.yazi(config, path)
  if utils.is_yazi_available() ~= true then
    print('Please install yazi. Check documentation for more information')
    return
  end

  config =
    vim.tbl_deep_extend('force', configModule.default(), M.config, config or {})

  path = utils.selected_file_path(path)

  local prev_win = vim.api.nvim_get_current_win()

  local win = window.YaziFloatingWindow.new(config)
  win:open_and_display()

  os.remove(config.chosen_file_path)
  local cmd = string.format(
    'yazi "%s" --local-events "rename,delete,trash,move" --chooser-file "%s" > %s',
    vim.fn.fnameescape(path),
    config.chosen_file_path,
    config.events_file_path
  )

  if M.yazi_loaded == false then
    -- ensure that the buffer is closed on exit
    local job_id = vimfn.termopen(cmd, {
      ---@diagnostic disable-next-line: unused-local
      on_exit = function(_job_id, code, _event)
        M.yazi_loaded = false
        if code ~= 0 then
          print(
            "yazi.nvim: had trouble opening yazi. Run ':checkhealth yazi' for more information."
          )
          return
        end

        utils.on_yazi_exited(prev_win, win, config)

        local events = utils.read_events_file(config.events_file_path)
        event_handling.process_events_emitted_from_yazi(events)
      end,
    })

    config.hooks.yazi_opened(path, win.content_buffer, config)
    config.set_keymappings_function(win.content_buffer, config)
    win.on_resized = function(event)
      vim.fn.jobresize(job_id, event.win_width, event.win_height)
    end
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

  if M.config.open_for_directories == true then
    ---@param file string
    ---@param bufnr number
    local function open_yazi_in_directory(file, bufnr)
      if vim.fn.isdirectory(file) == 1 then
        -- A buffer was opened for a directory.
        -- Remove the buffer as we want to show yazi instead
        vim.api.nvim_buf_delete(bufnr, { force = true })
        M.yazi(M.config, file)
      end
    end

    local yazi_augroup = vim.api.nvim_create_augroup('yazi', { clear = true })

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
    open_yazi_in_directory(vim.fn.expand('%:p'), vim.api.nvim_get_current_buf())
  end
end

return M
