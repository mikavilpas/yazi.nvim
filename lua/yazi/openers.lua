local M = {}

local function delete_empty_path_buffers()
  local buffers = vim.api.nvim_list_bufs()
  if #buffers == 2 then
    for _, buf in ipairs(buffers) do
      local file_path = vim.api.nvim_buf_get_name(buf)
      if file_path == '' then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

---@param chosen_file string
function M.open_file(chosen_file)
  delete_empty_path_buffers()
  vim.cmd(string.format('edit %s', vim.fn.fnameescape(chosen_file)))
end

---@param chosen_file string
function M.open_file_in_vertical_split(chosen_file)
  vim.cmd(string.format('vsplit %s', vim.fn.fnameescape(chosen_file)))
end

---@param chosen_file string
function M.open_file_in_horizontal_split(chosen_file)
  vim.cmd(string.format('split %s', vim.fn.fnameescape(chosen_file)))
end

---@param chosen_file string
function M.open_file_in_tab(chosen_file)
  vim.cmd(string.format('tabedit %s', vim.fn.fnameescape(chosen_file)))
end

---@param chosen_files string[]
function M.send_files_to_quickfix_list(chosen_files)
  vim.fn.setqflist({}, 'r', {
    title = 'Yazi',
    items = vim.tbl_map(function(file)
      -- append / to directories
      local path = file
      if vim.fn.isdirectory(file) == 1 then
        path = file .. '/'
      end

      return {
        filename = path,
        text = path,
      }
    end, chosen_files),
  })

  -- open the quickfix window
  vim.cmd('copen')
end

return M
