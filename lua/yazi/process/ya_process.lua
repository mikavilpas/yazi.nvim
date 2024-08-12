---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziSessionHighlighter =
  require("yazi.buffer_highlighting.yazi_session_highlighter")

---@class (exact) YaProcess
---@field public events YaziEvent[] "The events that have been received from yazi"
---@field public new fun(config: YaziConfig, yazi_id: string): YaProcess
---@field public hovered_url? string "The path that is currently hovered over in this yazi. Only works if `use_yazi_client_id_flag` is set to true."
---@field private config YaziConfig
---@field private yazi_id? string "The YAZI_ID of the yazi process. Can be nil if this feature is not in use."
---@field private ya_process vim.SystemObj
---@field private retries integer
---@field private highlighter YaziSessionHighlighter
local YaProcess = {}
---@diagnostic disable-next-line: inject-field
YaProcess.__index = YaProcess

---@param config YaziConfig
---@param yazi_id string
function YaProcess.new(config, yazi_id)
  local self = setmetatable({}, YaProcess)

  if config.use_yazi_client_id_flag == true then
    self.yazi_id = yazi_id
  end

  self.config = config
  self.events = {}
  self.retries = 0
  self.highlighter = YaziSessionHighlighter.new()

  return self
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

---@param paths Path[]
function YaProcess:get_yazi_command(paths)
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

  if self.yazi_id then
    table.insert(command_words, "--client-id")
    table.insert(command_words, self.yazi_id)
  end

  command_words = remove_duplicates(command_words)

  return table.concat(command_words, " ")
end

function YaProcess:kill()
  Log:debug("Killing ya process")
  pcall(self.ya_process.kill, self.ya_process, "sigterm")
  self.highlighter:clear_highlights()
end

function YaProcess:wait(timeout)
  Log:debug("Waiting for ya process to exit")
  self.ya_process:wait(timeout)
  return self.events
end

function YaProcess:start()
  local ya_command = { "ya", "sub", "rename,delete,trash,move,cd,hover,bulk" }
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

      Log:debug(string.format("ya stdout: '%s'", data))

      data = vim.split(data, "\n", { plain = true, trimempty = true })

      local parsed = utils.safe_parse_events(data)
      -- Log:debug(string.format('Parsed events: %s', vim.inspect(parsed)))

      for _, event in ipairs(parsed) do
        if event.type == "hover" then
          ---@cast event YaziHoverEvent
          if event.yazi_id == self.yazi_id then
            Log:debug(
              string.format("Changing the last hovered_url to %s", event.url)
            )
            self.hovered_url = event.url
          end
          vim.schedule(function()
            self.highlighter:highlight_buffers_when_hovered(
              event.url,
              self.config
            )

            local event_handling =
              require("yazi.event_handling.nvim_event_handling")
            event_handling.emit("YaziDDSHover", event)
          end)
        else
          self.events[#self.events + 1] = event
        end
      end
    end,

    ---@param obj vim.SystemCompleted
    on_exit = function(obj)
      Log:debug(string.format("ya process exited with code: %s", obj.code))
    end,
  })

  return self
end

return YaProcess
