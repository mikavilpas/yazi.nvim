local M = {}

---@param command string
---@param chosen_file string
local function edit_file(command, chosen_file)
  local ok, err = pcall(function()
    vim.cmd(string.format("%s %s", command, vim.fn.fnameescape(chosen_file)))
  end)
  if ok then
    return
  end

  if tostring(err):find("E325:", 1, true) then
    return
  end

  error(err, 0)
end

---@param chosen_file string
function M.open_file(chosen_file)
  edit_file("edit", chosen_file)
end

---@param chosen_file string
function M.open_file_in_vertical_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    edit_file("vsplit", chosen_file)
  end
end

---@param chosen_file string
function M.open_file_in_horizontal_split(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    edit_file("split", chosen_file)
  end
end

---@param chosen_file string
function M.open_file_in_tab(chosen_file)
  local is_directory = vim.fn.isdirectory(chosen_file) == 1
  if not is_directory then
    edit_file("tabedit", chosen_file)
  end
end

---@param chosen_files string[]
function M.open_multiple_files(chosen_files)
  local quoted = vim.tbl_map(vim.fn.fnameescape, chosen_files)
  vim.cmd.args({ table.concat(quoted, " ") })
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
