local fn = vim.fn
local RenameableBuffer = require('yazi.renameable_buffer')

local M = {}

---@return boolean
function M.is_yazi_available()
  return fn.executable('yazi') == 1
end

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

---@param path string?
---@return string
function M.selected_file_path(path)
  if path == '' or path == nil then
    path = vim.fn.expand('%:p')
  end
  if path == '' or path == nil then
    path = vim.fn.expand('%:p:h')
  end
  if path == '' or path == nil then
    path = vim.fn.expand('%:p')
  end

  return path
end

-- Returns parsed events from the yazi events file
---@param events_file_lines string[]
---@return YaziRenameEvent[]
function M.parse_events(events_file_lines)
  ---@type string[]
  local events = {}

  for _, line in ipairs(events_file_lines) do
    local parts = vim.split(line, ',')
    local type = parts[1]

    -- selene: allow(if_same_then_else)
    if type == 'rename' then
      -- example of a rename event:

      -- rename,1712242143209837,1712242143209837,{"tab":0,"from":"/Users/mikavilpas/git/yazi/LICENSE","to":"/Users/mikavilpas/git/yazi/LICENSE2"}
      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ',', 4, #parts)

      ---@type YaziRenameEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.fn.json_decode(data_string),
      }
      table.insert(events, event)
    elseif type == 'move' then
      -- example of a move event:
      -- move,1712854829131439,1712854829131439,{"items":[{"from":"/tmp/test/test","to":"/tmp/test"}]}
      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ',', 4, #parts)

      ---@type YaziMoveEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.fn.json_decode(data_string),
      }
      table.insert(events, event)
    elseif type == 'delete' then
      -- example of a delete event:
      -- delete,1712766606832135,1712766606832135,{"urls":["/tmp/test-directory/test_2"]}

      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ',', 4, #parts)

      ---@type YaziDeleteEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.fn.json_decode(data_string),
      }
      table.insert(events, event)
    elseif type == 'trash' then
      -- example of a trash event:
      -- trash,1712766606832135,1712766606832135,{"urls":["/tmp/test-directory/test_2"]}

      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ',', 4, #parts)

      ---@type YaziTrashEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.fn.json_decode(data_string),
      }
      table.insert(events, event)
    end
  end

  return events
end

---@param path string
---@return YaziEvent[]
function M.read_events_file(path)
  local success, events_file_lines = pcall(vim.fn.readfile, path)
  os.remove(path)
  if not success then
    return {}
  end

  -- selene: allow(shadowing)
  ---@diagnostic disable-next-line: redefined-local
  local success, events = pcall(M.parse_events, events_file_lines)
  if not success then
    return {}
  end

  return events
end

---@return RenameableBuffer[]
function M.get_open_buffers()
  ---@type RenameableBuffer[]
  local open_buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path ~= '' and path ~= nil then
      local renameable_buffer = RenameableBuffer.new(bufnr, path)
      open_buffers[#open_buffers + 1] = renameable_buffer
    end
  end

  return open_buffers
end

---@param path string
---@return boolean
function M.is_buffer_open(path)
  local open_buffers = M.get_open_buffers()
  for _, buffer in ipairs(open_buffers) do
    if buffer:matches_exactly(path) then
      return true
    end
  end

  return false
end

---@param instruction RenameableBuffer
---@return nil
function M.rename_or_close_buffer(instruction)
  -- If the target buffer is already open in neovim, just close the old buffer.
  -- It causes an error to try to rename to a buffer that's already open.
  if M.is_buffer_open(instruction.path.filename) then
    vim.api.nvim_buf_delete(instruction.bufnr, {})
  else
    vim.api.nvim_buf_set_name(instruction.bufnr, instruction.path.filename)
  end
end

---@param prev_win integer
---@param floating_window_id integer
---@param floating_window_buffer integer
---@param config YaziConfig
function M.on_yazi_exited(
  prev_win,
  floating_window_id,
  floating_window_buffer,
  config
)
  vim.cmd('silent! :checktime')

  -- open the file that was chosen
  if not vim.api.nvim_win_is_valid(prev_win) then
    return
  end

  if vim.api.nvim_win_is_valid(floating_window_id) then
    vim.api.nvim_win_close(floating_window_id, true)
  end

  vim.api.nvim_set_current_win(prev_win)
  if M.file_exists(config.chosen_file_path) == true then
    local chosen_files = vim.fn.readfile(config.chosen_file_path)

    if #chosen_files > 1 then
      config.hooks.yazi_opened_multiple_files(chosen_files, config)
    else
      local chosen_file = chosen_files[1]
      config.hooks.yazi_closed_successfully(chosen_file, config)
      if chosen_file then
        config.open_file_function(chosen_file, config)
      end
    end
  end

  if
    vim.api.nvim_buf_is_valid(floating_window_buffer)
    and vim.api.nvim_buf_is_loaded(floating_window_buffer)
  then
    vim.api.nvim_buf_delete(floating_window_buffer, { force = true })
  end
end

return M
