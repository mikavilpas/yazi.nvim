local fn = vim.fn
local iterators = require('plenary.iterators')

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
    end
  end

  return events
end

---@param path string
---@return YaziRenameEvent[]
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

---@param rename_events YaziRenameEvent[]
---@return YaziBufferRenameInstruction[]
function M.get_buffers_that_need_renaming_after_yazi_exited(rename_events)
  local buffers = iterators
    .iter(vim.api.nvim_list_bufs())
    :filter(function(buffer)
      if vim.api.nvim_buf_get_name(buffer) == '' then
        return false
      end

      return true
    end)
    :map(function(buffer)
      -- the buffer is found if
      -- * the buffer name matches the original name
      -- * or the buffer's file is under a directory that was renamed (also nested directories)
      for _, event in ipairs(rename_events) do
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        if event.data.from == buffer_name then
          ---@type YaziBufferRenameInstruction
          return {
            buffer = buffer,
            to = event.data.to,
          }
        end

        local starts_with = buffer_name:sub(1, #event.data.from)
          == event.data.from
        if starts_with then
          ---@type YaziBufferRenameInstruction
          return {
            buffer = buffer,
            to = event.data.to .. buffer_name:sub(#event.data.from + 1),
          }
        end
      end
    end)
    :tolist()

  return buffers
end

return M
