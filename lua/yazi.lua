local window = require('yazi.window')
local utils = require('yazi.utils')
local vimfn = require('yazi.vimfn')
local config = require('yazi.config')

local M = {}

M.yazi_loaded = false

local yazi_nvim_events_path = '/tmp/yazi.nvim.events.txt'

--- :Yazi entry point
---@param path string? defaults to the current file or the working directory
function M.yazi(path)
  if utils.is_yazi_available() ~= true then
    print('Please install yazi. Check documentation for more information')
    return
  end

  path = utils.selected_file_path(path)

  local prev_win = vim.api.nvim_get_current_win()

  local win, buffer = window.open_floating_window()

  os.remove(M.config.chosen_file_path)
  local cmd = string.format(
    'yazi "%s" --local-events "rename" --chooser-file "%s" > %s',
    path,
    M.config.chosen_file_path,
    yazi_nvim_events_path
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
          -- NOTE the types for nvim_ apis are inaccurate so we need to typecast
          ---@cast win integer
          vim.api.nvim_win_close(win, true)
          vim.api.nvim_set_current_win(prev_win)
          if
            code == 0 and utils.file_exists(M.config.chosen_file_path) == true
          then
            local chosen_file = vim.fn.readfile(M.config.chosen_file_path)[1]
            if chosen_file then
              vim.cmd(string.format('edit %s', chosen_file))
            end
          end

          ---@cast buffer integer
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.api.nvim_buf_is_loaded(buffer)
          then
            vim.api.nvim_buf_delete(buffer, { force = true })
          end
        end

        -- process events emitted from yazi
        local rename_events = utils.read_events_file(yazi_nvim_events_path)
        local renames =
          utils.get_buffers_that_need_renaming_after_yazi_exited(rename_events)

        for _, event in ipairs(renames) do
          vim.api.nvim_buf_set_name(event.bufnr, event.path.filename)
        end
      end,
    })
  end
  vim.schedule(function()
    vim.cmd('startinsert')
  end)
end

M.config = config.default()

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
          require('yazi').yazi(file)
        end
      end,
      group = yazi_augroup,
    })
  end
end

return M
