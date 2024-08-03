local M = {}

---@param yazi_augroup integer
function M.hijack_netrw(yazi_augroup)
  local Log = require('yazi.log')

  ---@param file string
  ---@param bufnr number
  local function open_yazi_in_directory(file, bufnr)
    if vim.fn.isdirectory(file) == 1 then
      local winid = vim.api.nvim_get_current_win()
      local dir_bufnr = vim.api.nvim_get_current_buf()

      -- A buffer was opened for a directory.
      -- Remove the buffer as we want to show yazi instead
      local empty_buffer = vim.api.nvim_create_buf(true, false)
      Log:debug(
        string.format(
          'Removing buffer %s for directory %s and replacing it with empty buffer %s',
          dir_bufnr,
          file,
          empty_buffer
        )
      )
      pcall(function()
        vim.api.nvim_win_set_buf(winid, empty_buffer)
        Log:debug(
          string.format('Set buffer %s for window %s', empty_buffer, winid)
        )
      end)
      vim.schedule(function()
        Log:debug(
          string.format('Deleting buffer %s for directory %s', dir_bufnr, file)
        )

        vim.api.nvim_buf_delete(bufnr, { force = true })
        Log:debug(
          string.format('Deleted buffer %s for directory %s', bufnr, file)
        )

        Log:debug(string.format('Opening yazi for directory %s', file))
        require('yazi').yazi(M.config, file)
      end)
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

return M
