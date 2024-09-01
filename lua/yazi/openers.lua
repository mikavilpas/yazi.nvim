local M = {}

---@param chosen_file string
function M.open_file(chosen_file)
  vim.cmd(string.format("edit %s", vim.fn.fnameescape(chosen_file)))
end

---@param chosen_file string
function M.open_file_in_vertical_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("vsplit %s", vim.fn.fnameescape(chosen_file)))
  end
end

---@param chosen_file string
function M.open_file_in_horizontal_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("split %s", vim.fn.fnameescape(chosen_file)))
  end
end

---@param chosen_file string
function M.open_file_in_tab(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("tabedit %s", vim.fn.fnameescape(chosen_file)))
  end
end

---@param chosen_files string[]
function M.open_multiple_files(chosen_files)
  local quoted = vim.tbl_map(vim.fn.fnameescape, chosen_files)
  vim.cmd("args" .. table.concat(quoted, " "))
end

---@param chosen_files string[]
function M.send_files_to_quickfix_list(chosen_files)
  vim.fn.setqflist({}, "r", {
    title = "Yazi",
    items = vim.tbl_map(function(file)
      -- append / to directories
      local path = file
      if vim.fn.isdirectory(file) == 1 then
        path = file .. "/"
      end

      return {
        filename = path,
        text = path,
      }
    end, chosen_files),
  })

  -- open the quickfix window
  vim.cmd("copen")
end

return M
