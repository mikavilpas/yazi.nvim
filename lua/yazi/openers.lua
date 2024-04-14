local M = {}

---@param chosen_file string
function M.open_file(chosen_file)
  vim.cmd(string.format('edit %s', chosen_file))
end

---@param chosen_file string
function M.open_file_in_vertical_split(chosen_file)
  vim.cmd(string.format('vsplit %s', chosen_file))
end

---@param chosen_file string
function M.open_file_in_horizontal_split(chosen_file)
  vim.cmd(string.format('split %s', chosen_file))
end

---@param chosen_file string
function M.open_file_in_tab(chosen_file)
  vim.cmd(string.format('tabedit %s', chosen_file))
end

---@param chosen_files string[]
function M.send_files_to_quickfix_list(chosen_files)
  vim.fn.setqflist({}, 'r', {
    title = 'Yazi',
    items = vim.tbl_map(function(file)
      return {
        filename = file,
        lnum = 1,
        text = file,
      }
    end, chosen_files),
  })

  -- open the quickfix window
  vim.cmd('copen')
end

return M
