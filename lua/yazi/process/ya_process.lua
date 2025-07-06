---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")

---@class(exact) YaProcess
---@field public known_yazis table<string, YaziState> # yazi_id -> ready state
---@field public is_running boolean "Whether the ya process is currently running. `false" if the process has exited."
---@field private config YaziConfig
---@field public ya_process vim.SystemObj
---@field private retries integer
local YaProcess = {}
---@diagnostic disable-next-line: inject-field
YaProcess.__index = YaProcess

YaProcess.known_yazis = setmetatable({}, {
  __mode = "v", -- see `:help lua-weaktable`
})

---@param config YaziConfig
---@diagnostic disable-next-line: inject-field
function YaProcess.new(config)
  local self = setmetatable({}, YaProcess)

  self.config = config
  self.retries = 0
  self.is_running = false

  return self
end

--- Connect a yazi instance so that it can receive events from the ya process.
---@param state YaziState
function YaProcess:register_yazi(state)
  if not YaProcess.known_yazis[state.yazi_id] then
    Log:debug(string.format("Registering yazi with id %s", state.yazi_id))
    YaProcess.known_yazis[state.yazi_id] = state
  else
    Log:debug(
      string.format(
        "Yazi with id %s already registered, ignoring.",
        state.yazi_id
      )
    )
  end
end

---@param yazi_id string
function YaProcess:is_ready(yazi_id)
  local state = YaProcess.known_yazis[yazi_id]
  local has_process = self.ya_process ~= nil
  local is_ready = state.ready == true
  local ready = has_process and is_ready
  return ready, {
    has_process = has_process,
    is_ready = is_ready,
  }
end

---@param items string[]
local function remove_duplicates(items)
  local seen = {}
  local result = {}
  for _, word in ipairs(items) do
    if not seen[word] then
      seen[word] = true
      result[#result + 1] = word
    end
  end

  return result
end

---@param yazi_id string
---@param paths Path[]
function YaProcess:get_yazi_command(yazi_id, paths)
  local command_words = { "yazi" }

  if self.config.open_multiple_tabs == true then
    for _, path in ipairs(paths) do
      table.insert(command_words, vim.fn.shellescape(path.filename))
    end
  else
    table.insert(command_words, vim.fn.shellescape(paths[1].filename))
  end

  table.insert(command_words, "--chooser-file")
  table.insert(command_words, self.config.chosen_file_path)

  if yazi_id then
    table.insert(command_words, "--client-id")
    table.insert(command_words, yazi_id)
  end

  command_words = remove_duplicates(command_words)

  return table.concat(command_words, " ")
end

---@param timeout integer
function YaProcess:kill_and_wait(timeout)
  Log:debug("Killing ya process")
  pcall(self.ya_process.kill, self.ya_process, "sigterm")

  Log:debug("Waiting for ya process to exit")
  self.ya_process:wait(timeout)
end

function YaProcess:start()
  local event_kinds = {
    "rename",
    "delete",
    "trash",
    "move",
    "cd",
    "hover",
    "bulk",
    -- when ya starts, it will send a "hi" event to all yazis. They respond
    -- with "hey" to acknowledge this. We can use this to detect when ya is
    -- ready, so that integration-tests can safely start.
    "hey",
  }

  ---@type table<string,boolean>
  local interesting_events = {}
  if self.config.forwarded_dds_events ~= nil then
    for _, event_kind in ipairs(self.config.forwarded_dds_events) do
      event_kinds[#event_kinds + 1] = event_kind
      interesting_events[event_kind] = true
    end
  end

  local ya_command = {
    "ya",
    "sub",
    table.concat(event_kinds, ","),
  }
  Log:debug(
    string.format(
      "Opening ya with the command: (%s), attempt %s",
      table.concat(ya_command, " "),
      self.retries
    )
  )

  self.ya_process = vim.system(ya_command, {
    -- • text: (boolean) Handle stdout and stderr as text.
    -- Replaces `\r\n` with `\n`.
    text = true,
    stderr = function(err, data)
      if err then
        Log:debug(string.format("ya stderr error: '%s'", data))
      end

      if data == nil then
        -- weird event, ignore
        return
      end

      Log:debug(string.format("ya stderr: '%s'", data))

      if data:find("No running Yazi instance found") then
        if self.retries < 5 then
          Log:debug(
            "Looks like starting ya failed because yazi had not started yet. Retrying to open ya..."
          )
          self.retries = self.retries + 1
          vim.defer_fn(function()
            self:start()
          end, 50)
        else
          Log:debug("Failed to open ya after 5 retries")
        end
      end
    end,

    stdout = function(err, data)
      if err then
        Log:debug(string.format("ya stdout error: '%s'", data))
      end
      data = data or ""
      data = data:gsub("\n+", "\n")

      if not data:match("^hey") then
        Log:debug(string.format("ya stdout: '%s'", data))
      end

      data = vim.split(data, "\n", { plain = true, trimempty = true })

      local parsed = utils.safe_parse_events(data)
      -- Log:debug(string.format("Parsed events: %s", vim.inspect(parsed)))

      self:process_events(parsed, interesting_events)
    end,

    ---@param obj vim.SystemCompleted
    on_exit = function(obj)
      Log:debug(string.format("ya process exited with code: %s", obj.code))
      self.is_running = false
    end,
  })
  self.is_running = true

  return self
end

---@param events YaziEvent[]
---@param forwarded_event_kinds table<string,boolean>
function YaProcess:process_events(events, forwarded_event_kinds)
  local nvim_event_handling = require("yazi.event_handling.nvim_event_handling")
  local yazi_event_handling = require("yazi.event_handling.yazi_event_handling")

  for _, event in ipairs(events) do
    if
      -- handle these events globally, not per yazi instance
      event.type == "rename"
      or event.type == "move"
      or event.type == "bulk"
      or event.type == "trash"
      or event.type == "delete"
    then
      vim.schedule(function()
        if
          event.type == "rename"
          or event.type == "move"
          or event.type == "bulk"
        then
          local success, result = pcall(function()
            nvim_event_handling.emit_renamed_or_moved_event(event)
          end)
          if not success then
            Log:debug(vim.inspect({
              "Failed to emit YaziRenamedOrMoved event",
              event,
              result,
            }))
          end
        end

        yazi_event_handling.process_file_event(event, self.config)
      end)
    else
      -- forward events that are meant to be received by a specific yazi
      -- instance that yazi.nvim controls
      local state = YaProcess.known_yazis[event.yazi_id]
      if not state then
        if forwarded_event_kinds[event.type] ~= nil then
          vim.schedule(function()
            nvim_event_handling.emit("YaziDDSCustom", event)
          end)
        elseif event.type == "cycle-buffer" then
          -- ideally cycle-buffer events should state which yazi.nvim instance
          -- should receive and handle them. Right now this is not supported,
          -- and it seems like the user must make changes to their
          -- configuration to make this happen. Let's work around this to "just
          -- work" in 90% of the cases, and we can have a more accurate
          -- implementation available later on if needed.
          local context = require("yazi").active_contexts:peek()
          if context then
            vim.schedule(function()
              ---@cast context YaziActiveContext
              ---@cast event YaziNvimCycleBufferEvent
              require("yazi.keybinding_helpers").cycle_open_buffers(context)
            end)
          end
        else
          Log:debug(
            string.format(
              "Ignoring event for unknown yazi_id %s. Event: %s",
              event.yazi_id,
              vim.inspect(event)
            )
          )
        end
      else
        if event.type == "hey" then
          -- mark the yazi as ready

          ---@cast event YaziHeyEvent
          if state then -- might receive `hey` multiple times
            if state.on_first_output ~= nil then
              Log:debug(
                string.format("ya has become ready, yazi_id: %s", event.yazi_id)
              )
              state.on_first_output()
              state.on_first_output = nil
            end
            state.ready = true
          else
            Log:debug(
              string.format(
                "Received 'hey' event for unknown yazi_id: %s",
                event.yazi_id
              )
            )
          end
        elseif event.type == "cd" or event.type == "hover" then
          state.on_event(event)
        else
          -- TODO what events are these exactly?
          vim.schedule(function()
            yazi_event_handling.process_event_emitted_from_yazi(
              event,
              self.config
            )
          end)
        end
      end
    end
  end
end

return YaProcess
