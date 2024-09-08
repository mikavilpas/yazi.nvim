local M = {}

---@param yazi_augroup integer
function M.hijack_netrw(yazi_augroup)
  local Log = require("yazi.log")

  ---@param file string
  ---@param bufnr number
  local function open_yazi_in_directory(file, bufnr)
    if vim.fn.isdirectory(file) ~= 1 then
      return
    end

    local winid = vim.api.nvim_get_current_win()
    local dir_bufnr = vim.api.nvim_get_current_buf()

    -- A buffer was opened for a directory.
    -- Remove the buffer as we want to show yazi instead
    local empty_buffer = vim.api.nvim_create_buf(true, false)
    local next_buffer = vim.fn.bufnr("#") or empty_buffer
    Log:debug(
      string.format(
        "Removing buffer %s for directory %s and replacing it with the next buffer %s",
        dir_bufnr,
        file,
        next_buffer
      )
    )
    vim.schedule(function()
      Log:debug(
        string.format("Deleting buffer %s for directory %s", dir_bufnr, file)
      )

      pcall(function()
        vim.api.nvim_win_set_buf(winid, next_buffer)
        Log:debug(
          string.format("Set buffer %s for window %s", next_buffer, winid)
        )
      end)
      vim.api.nvim_buf_delete(bufnr, { force = true })
      if next_buffer ~= empty_buffer then
        vim.api.nvim_buf_delete(empty_buffer, { force = true })
      end
      Log:debug(
        string.format("Deleted buffer %s for directory %s", bufnr, file)
      )

      Log:debug(string.format("Opening yazi for directory %s", file))
      require("yazi").yazi(M.config, file)

      -- HACK: for some reason, the cursor is not in insert mode when opening
      -- yazi from the command line with `neovim .`, so just simulate
      -- pressing "i" to enter insert mode :) It did nothing when when I
      -- tried using vim.cmd('startinsert') or vim.cmd('normal! i')
      if vim.fn.mode(true) == "t" then
        vim.api.nvim_feedkeys("i", "n", false)
      end
    end)
  end

  -- disable netrw, the built-in file explorer
  vim.cmd("silent! autocmd! FileExplorer *")

  -- executed before starting to edit a new buffer.
  vim.api.nvim_create_autocmd("BufAdd", {
    pattern = "*",
    ---@param ev yazi.AutoCmdEvent
    callback = function(ev)
      if vim.g.SessionLoad == 1 then
        -- Fix https://github.com/mikavilpas/yazi.nvim/issues/440
        -- See `:h SessionLoad-variable`
        return
      end
      open_yazi_in_directory(ev.file, ev.buf)
    end,
    group = yazi_augroup,
  })

  -- When opening neovim with "nvim ." or "nvim <directory>", the current
  -- buffer is already open at this point. If we have already opened a
  -- directory, display yazi instead.
  open_yazi_in_directory(
    vim.b.netrw_curdir or vim.fn.expand("%:p"),
    vim.api.nvim_get_current_buf()
  )
end

return M
