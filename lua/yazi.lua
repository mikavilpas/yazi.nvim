local window = require('yazi.window')
local utils = require('yazi.utils')
local vimfn = require('yazi.vimfn')
local configModule = require('yazi.config')
local event_handling = require('yazi.event_handling')

local M = {}

M.yazi_loaded = false

--- :Yazi entry point
---@param config? YaziConfig?
---@param path? string
---@diagnostic disable-next-line: redefined-local
function M.yazi(config, path)
  if utils.is_yazi_available() ~= true then
    print('Please install yazi. Check documentation for more information')
    return
  end

  config = vim.tbl_deep_extend('force', M.config, config or {})

  path = utils.selected_file_path(path)

  local prev_win = vim.api.nvim_get_current_win()

  local win = window.YaziFloatingWindow.new(config)
  win:open_and_display()

  os.remove(config.chosen_file_path)
  local cmd = string.format(
    'yazi "%s" --local-events "rename,delete,trash,move" --chooser-file "%s" > %s',
    path,
    config.chosen_file_path,
    config.events_file_path
  )

  if M.yazi_loaded == false then
    -- ensure that the buffer is closed on exit
    vimfn.termopen(cmd, {
      ---@diagnostic disable-next-line: unused-local
      on_exit = function(_job_id, code, _event)
        M.yazi_loaded = false
        if code ~= 0 then
          print('yazi exited with code', code)
          return
        end

        utils.on_yazi_exited(prev_win, win, config)

        local events = utils.read_events_file(config.events_file_path)
        event_handling.process_events_emitted_from_yazi(events)
      end,
    })

    config.hooks.yazi_opened(path, win.content_buffer, config)
    config.set_keymappings_function(win.content_buffer, config)
  end
  vim.schedule(function()
    vim.cmd('startinsert')
  end)
end

M.config = configModule.default()

---@param opts YaziConfig?
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  if M.config.open_for_directories == true then
    local yazi_augroup = vim.api.nvim_create_augroup('yazi', { clear = true })

    -- disable netrw, the built-in file explorer
    vim.cmd('silent! autocmd! FileExplorer *')

    -- executed before starting to edit a new buffer.
    vim.api.nvim_create_autocmd('BufAdd', {
      pattern = '*',
      callback = function(ev)
        local file = ev.file
        if vim.fn.isdirectory(file) == 1 then
          local bufnr = ev.buf
          -- A buffer was opened for a directory.
          -- Remove the buffer as we want to show yazi instead
          vim.api.nvim_buf_delete(bufnr, { force = true })
          M.yazi(M.config, file)
        end
      end,
      group = yazi_augroup,
    })
  end
end

return M
