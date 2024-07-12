---@module "plenary.path"

---@alias WindowId integer

local Log = require('yazi.log')
local utils = require('yazi.utils')
local highlight_hovered_buffer =
  require('yazi.buffer_highlighting.highlight_hovered_buffer')

---@class (exact) YaProcess
---@field public events YaziEvent[] "The events that have been received from yazi"
---@field public new fun(config: YaziConfig): YaProcess
---@field private config YaziConfig
---@field private ya_process vim.SystemObj
---@field private retries integer
local YaProcess = {}
---@diagnostic disable-next-line: inject-field
YaProcess.__index = YaProcess

---@param config YaziConfig
function YaProcess.new(config)
  local self = setmetatable({}, YaProcess)
  self.config = config
  self.events = {}
  self.retries = 0

  return self
end

---@param path Path
function YaProcess:get_yazi_command(path)
  return string.format(
    'yazi %s --chooser-file "%s"',
    vim.fn.shellescape(path.filename),
    self.config.chosen_file_path
  )
end

function YaProcess:kill()
  Log:debug('Killing ya process')
  pcall(self.ya_process.kill, self.ya_process, 'sigterm')
  highlight_hovered_buffer.clear_highlights()
end

function YaProcess:wait(timeout)
  Log:debug('Waiting for ya process to exit')
  self.ya_process:wait(timeout)
  return self.events
end

function YaProcess:start()
  local ya_command = { 'ya', 'sub', 'rename,delete,trash,move,cd,hover,bulk' }
  Log:debug(
    string.format(
      'Opening ya with the command: (%s), attempt %s',
      table.concat(ya_command, ' '),
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

      if data:find('No running Yazi instance found') then
        if self.retries < 5 then
          Log:debug(
            'Looks like starting ya failed because yazi had not started yet. Retrying to open ya...'
          )
          self.retries = self.retries + 1
          vim.defer_fn(function()
            self:start()
          end, 50)
        else
          Log:debug('Failed to open ya after 5 retries')
        end
      end
    end,

    stdout = function(err, data)
      if err then
        Log:debug(string.format("ya stdout error: '%s'", data))
      end
      data = data or ''

      Log:debug(string.format("ya stdout: '%s'", data))

      data = vim.split(data, '\n', { plain = true, trimempty = true })

      local parsed = utils.safe_parse_events(data)
      Log:debug(string.format('Parsed events: %s', vim.inspect(parsed)))

      for _, event in ipairs(parsed) do
        if event.type == 'hover' then
          vim.schedule(function()
            ---@cast event YaziHoverEvent
            highlight_hovered_buffer.highlight_hovered_buffer(
              event.url,
              self.config.highlight_groups
            )
          end)
        else
          self.events[#self.events + 1] = event
        end
      end
    end,

    ---@param obj vim.SystemCompleted
    on_exit = function(obj)
      Log:debug(string.format('ya process exited with code: %s', obj.code))
    end,
  })

  return self
end

return YaProcess
