local RenameableBuffer = require("yazi.renameable_buffer")
local plenary_path = require("plenary.path")

local M = {}

---@param config YaziConfig
---@param current_file_dir string
---@param selected_file string
---@return string
function M.relative_path(config, current_file_dir, selected_file)
  local command = config.integrations.resolve_relative_path_application
  assert(
    command ~= nil,
    "resolve_relative_path_application must be set. Please report this as a bug."
  )

  if vim.fn.executable(command) == 0 then
    local msg = string.format(
      "error copying relative_path - the executable `%s` was not found. Try running `:healthcheck yazi` for more information.",
      command
    )

    vim.notify(msg)
    error(msg)
  end

  assert(command ~= nil, "realpath command must be set")

  ---@type Path
  local start_path = plenary_path:new(current_file_dir)
  local start_directory = nil
  if start_path:is_dir() then
    start_directory = start_path
  else
    start_directory = start_path:parent()
  end

  local stdout, exit_code, stderr = require("plenary.job")
    :new({
      command = command,
      args = { "--relative-to", start_directory.filename, selected_file },
    })
    :sync()

  if exit_code ~= 0 or stdout == nil or stdout == "" then
    vim.notify("error copying relative_path, exit code " .. exit_code)
    error("error running command, exit code " .. exit_code)
    print(vim.inspect(stderr))
  end

  local path = stdout[1]

  return path
end

function M.is_yazi_available()
  return vim.fn.executable("yazi") == 1
end

function M.is_ya_available()
  return vim.fn.executable("ya") == 1
end

function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

---@param path string?
function M.selected_file_path(path)
  -- make sure the path is a full path
  if path == "" or path == nil then
    path = vim.fn.expand("%:p")
  end

  -- if the path is still empty (no file loaded / invalid buffer), try to get
  -- the directory of the current file.
  if path == "" or path == nil then
    path = vim.fn.expand("%:p:h")
  end

  -- if the path is still empty, try to get the current file
  if path == "" or path == nil then
    path = vim.fn.expand("%:p")
  end

  ---@type Path
  return plenary_path:new(path)
end

---@param path string?
function M.selected_file_paths(path)
  local selected_file_path = M.selected_file_path(path)
  ---@type Path[]
  local paths = { selected_file_path }

  for _, buffer in ipairs(M.get_visible_open_buffers()) do
    -- NOTE: yazi can only display up to 9 paths, and it's an error to give any
    -- more
    if
      #paths < 9
      and not buffer.renameable_buffer:matches_exactly(
        selected_file_path.filename
      )
    then
      table.insert(paths, buffer.renameable_buffer.path)
    end
  end

  return paths
end

---@param file_path string
---@return Path
function M.dir_of(file_path)
  ---@type Path
  local path = plenary_path:new(file_path)
  local parent = path:parent()

  -- for some reason, plenary is documented as returning table|unknown[]. we
  -- want the table version only
  assert(type(parent) == "table", "parent must be a table")

  return parent
end

-- Returns parsed events from the yazi events file
---@param events_file_lines string[]
function M.parse_events(events_file_lines)
  ---@type YaziEvent[]
  local events = {}

  for _, line in ipairs(events_file_lines) do
    local parts = vim.split(line, ",")
    local type = parts[1]

    -- selene: allow(if_same_then_else)
    if type == "rename" then
      -- example of a rename event:

      -- rename,1712242143209837,1712242143209837,{"tab":0,"from":"/Users/mikavilpas/git/yazi/LICENSE","to":"/Users/mikavilpas/git/yazi/LICENSE2"}
      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ",", 4, #parts)

      ---@type YaziRenameEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.json.decode(data_string),
      }
      table.insert(events, event)
    elseif type == "move" then
      -- example of a move event:
      -- move,1712854829131439,1712854829131439,{"items":[{"from":"/tmp/test/test","to":"/tmp/test"}]}
      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ",", 4, #parts)

      ---@type YaziMoveEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.json.decode(data_string),
      }
      table.insert(events, event)
    elseif type == "bulk" then
      -- example of a bulk event:
      -- bulk,0,1720800121065599,{"changes":{"/tmp/test-directory/test":"/tmp/test-directory/test2"}}
      local data = vim.json.decode(table.concat(parts, ",", 4, #parts))

      ---@type YaziBulkEvent
      local event = {
        type = "bulk",
        changes = data["changes"],
      }
      table.insert(events, event)
    elseif type == "delete" then
      -- example of a delete event:
      -- delete,1712766606832135,1712766606832135,{"urls":["/tmp/test-directory/test_2"]}
      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ",", 4, #parts)

      ---@type YaziDeleteEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.json.decode(data_string),
      }
      table.insert(events, event)
    elseif type == "trash" then
      -- example of a trash event:
      -- trash,1712766606832135,1712766606832135,{"urls":["/tmp/test-directory/test_2"]}

      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ",", 4, #parts)

      ---@type YaziTrashEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        data = vim.json.decode(data_string),
      }
      table.insert(events, event)
    elseif type == "cd" then
      -- example of a change directory (cd) event:
      -- cd,1716307611001689,1716307611001689,{"tab":0,"url":"/tmp/test-directory"}

      local timestamp = parts[2]
      local id = parts[3]
      local data_string = table.concat(parts, ",", 4, #parts)

      ---@type YaziChangeDirectoryEvent
      local event = {
        type = type,
        timestamp = timestamp,
        id = id,
        url = vim.json.decode(data_string)["url"],
      }
      table.insert(events, event)
    elseif type == "hover" then
      -- example of a hover event:
      -- hover,0,1720375364822700,{"tab":0,"url":"/tmp/test-directory/test"}
      local data_string = table.concat(parts, ",", 4, #parts)
      local yazi_id = parts[3]
      local json = vim.json.decode(data_string, {
        luanil = {
          array = true,
          object = true,
        },
      })

      -- sometimes ya sends a hover event without a url, not sure why
      ---@type string | nil
      local url = json["url"]

      ---@type YaziHoverEvent
      local event = {
        yazi_id = yazi_id,
        type = type,
        url = url or "",
      }
      table.insert(events, event)
    else
      require("yazi.log"):debug(string.format("Unknown event type: %s", type))
      -- Custom user event.
      -- It could look like this (with optional data at the end)
      -- MyMessageNoData,0,1731774290298033,
      local data_string = table.concat(parts, ",", 4, #parts)
      local yazi_id = parts[3]

      ---@type YaziCustomDDSEvent
      local event = {
        yazi_id = yazi_id,
        type = type,
        raw_data = data_string,
      }
      table.insert(events, event)
    end
  end

  return events
end

---@param event_lines string[]
function M.safe_parse_events(event_lines)
  local success, events = pcall(M.parse_events, event_lines)
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
    local type = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

    local is_ordinary_file = path ~= vim.NIL and path ~= "" and type == ""
    if is_ordinary_file then
      local renameable_buffer = RenameableBuffer.new(bufnr, path)
      open_buffers[#open_buffers + 1] = renameable_buffer
    end
  end

  return open_buffers
end

---@alias YaziVisibleBuffer { renameable_buffer: RenameableBuffer, window_id: integer }

function M.get_visible_open_buffers()
  local open_buffers = M.get_open_buffers()

  ---@type YaziVisibleBuffer[]
  local visible_open_buffers = {}
  for _, buffer in ipairs(open_buffers) do
    local windows = vim.api.nvim_tabpage_list_wins(0)
    for _, window_id in ipairs(windows) do
      if vim.api.nvim_win_get_buf(window_id) == buffer.bufnr then
        ---@type YaziVisibleBuffer
        local data = {
          renameable_buffer = buffer,
          window_id = window_id,
        }
        visible_open_buffers[#visible_open_buffers + 1] = data
      end
    end
  end

  return visible_open_buffers
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

function M.bufdelete(bufnr)
  local ok, bufdelete = pcall(function()
    return require("snacks.bufdelete")
  end)
  if ok then
    return bufdelete.delete({ buf = bufnr, force = true })
  else
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

---@param instruction RenameableBuffer
---@return nil
function M.rename_or_close_buffer(instruction)
  -- If the target buffer is already open in neovim, just close the old buffer.
  -- It causes an error to try to rename to a buffer that's already open.
  if M.is_buffer_open(instruction.path.filename) then
    pcall(function()
      vim.api.nvim_buf_delete(instruction.bufnr, { force = true })
    end)
  end

  pcall(function()
    vim.api.nvim_buf_set_name(instruction.bufnr, instruction.path.filename)
  end)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(instruction.bufnr) then
      vim.api.nvim_buf_call(instruction.bufnr, function()
        vim.cmd("edit!")
      end)
    end
  end)
end

---@param prev_win integer
---@param prev_buf integer
---@param window YaziFloatingWindow
---@param config YaziConfig
---@param selected_files string[]
---@param state YaziClosedState
function M.on_yazi_exited(
  prev_win,
  prev_buf,
  window,
  config,
  selected_files,
  state
)
  vim.cmd("silent! :checktime")

  window:close()

  do
    -- sanity check: make sure the previous window and buffer are still valid
    if not vim.api.nvim_win_is_valid(prev_win) then
      return
    end

    if vim.api.nvim_buf_is_valid(prev_buf) then
      vim.api.nvim_set_current_buf(prev_buf)
    end
  end

  vim.api.nvim_set_current_win(prev_win)
  if #selected_files <= 0 then
    config.hooks.yazi_closed_successfully(nil, config, state)
    return
  end

  if #selected_files > 1 then
    config.hooks.yazi_opened_multiple_files(selected_files, config, state)
    return
  end

  assert(#selected_files == 1)
  local chosen_file = selected_files[1]
  config.hooks.yazi_closed_successfully(chosen_file, config, state)
  if chosen_file then
    config.open_file_function(chosen_file, config, state)
  end
end

return M
