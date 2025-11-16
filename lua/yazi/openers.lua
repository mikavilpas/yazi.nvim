local M = {}

---@param chosen_file string
function M.open_file(chosen_file)
  vim.cmd(string.format("edit %s", vim.fs.normalize(chosen_file)))
end

---@param chosen_file string
function M.open_file_in_vertical_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("vsplit %s", vim.fs.normalize(chosen_file)))
  end
end

---@param chosen_file string
function M.open_file_in_horizontal_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("split %s", vim.fs.normalize(chosen_file)))
  end
end

---@param chosen_file string
function M.open_file_in_tab(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    vim.cmd(string.format("tabedit %s", vim.fs.normalize(chosen_file)))
  end
end

---@param chosen_files string[]
function M.open_multiple_files(chosen_files)
  local quote_path = function(path)
    return vim.fn.fnameescape(vim.fs.normalize(path))
  end
  local quoted_paths = vim.tbl_map(quote_path, chosen_files)
  vim.cmd.args({ table.concat(quoted_paths, " ") })
end

---@param chosen_files string[]
function M.send_files_to_quickfix_list(chosen_files)
  vim.fn.setqflist({}, "r", {
    title = "Yazi",
    items = vim.tbl_map(function(file)
      local path = vim.fs.normalize(file)

      if vim.fn.isdirectory(path) == 1 then
        path = path .. "/"
      end

      ---@type vim.quickfix.entry
      return {
        filename = path,
        text = path,
        col = 1,
        lnum = 1,
      }
    end, chosen_files),
  })

  -- open the quickfix window
  vim.cmd("copen")
end

return M
