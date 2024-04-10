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

  local win, buffer = window.open_floating_window(config)

  os.remove(config.chosen_file_path)
  local cmd = string.format(
    'yazi "%s" --local-events "rename,delete,trash" --chooser-file "%s" > %s',
    path,
    config.chosen_file_path,
    config.events_file_path
  )

  if M.yazi_loaded == false then
    -- ensure that the buffer is closed on exit
    vimfn.termopen(cmd, {
      ---@diagnostic disable-next-line: unused-local
      on_exit = function(_job_id, code, _event)
        if code ~= 0 then
          return
        end

        M.yazi_loaded = false
        vim.cmd('silent! :checktime')

        -- open the file that was chosen
        if vim.api.nvim_win_is_valid(prev_win) then
          vim.api.nvim_win_close(win, true)
          vim.api.nvim_set_current_win(prev_win)
          if
            code == 0 and utils.file_exists(config.chosen_file_path) == true
          then
            local chosen_file = vim.fn.readfile(config.chosen_file_path)[1]
            config.hooks.yazi_closed_successfully(chosen_file)
            if chosen_file then
              config.open_file_function(chosen_file)
            end
          end

          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.api.nvim_buf_is_loaded(buffer)
          then
            vim.api.nvim_buf_delete(buffer, { force = true })
          end
        end

        -- process events emitted from yazi
        local events = utils.read_events_file(config.events_file_path)

        for _, event in ipairs(events) do
          if event.type == 'rename' then
            ---@cast event YaziRenameEvent
            local rename_instructions =
              event_handling.get_buffers_that_need_renaming_after_yazi_exited(
                event.data
              )
            for _, instruction in ipairs(rename_instructions) do
              vim.api.nvim_buf_set_name(
                instruction.bufnr,
                instruction.path.filename
              )
            end
          elseif event.type == 'delete' then
            ---@cast event YaziDeleteEvent
            event_handling.process_delete_event(event)
          elseif event.type == 'trash' then
            -- selene: allow(if_same_then_else)
            ---@cast event YaziTrashEvent
            event_handling.process_delete_event(event)
          end
        end
      end,
    })

    config.hooks.yazi_opened(path)
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
