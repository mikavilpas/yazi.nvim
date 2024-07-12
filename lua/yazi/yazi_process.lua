---@module "plenary.path"

local YaProcess = require('yazi.process.ya_process')
local Log = require('yazi.log')
local utils = require('yazi.utils')
local LegacyEventReadingFromEventFile =
  require('yazi.process.legacy_events_from_file')

---@class YaziProcess
---@field private event_reader YaProcess | LegacyEventReadingFromEventFile "The process that reads events from yazi"
---@field public yazi_job_id integer
local YaziProcess = {}

---@diagnostic disable-next-line: inject-field
YaziProcess.__index = YaziProcess

---@param config YaziConfig
---@param path Path
---@param on_exit fun(code: integer, selected_files: string[], events: YaziEvent[])
function YaziProcess:start(config, path, on_exit)
  os.remove(config.chosen_file_path)

  Log:debug(
    string.format(
      'use_ya_for_events_reading: %s',
      config.use_ya_for_events_reading
    )
  )
  self.event_reader = config.use_ya_for_events_reading == true
      and YaProcess.new(config)
    or LegacyEventReadingFromEventFile:new(config)

  local yazi_cmd = self.event_reader:get_yazi_command(path)

  Log:debug(string.format('Opening yazi with the command: (%s)', yazi_cmd))
  self.yazi_job_id = vim.fn.termopen(yazi_cmd, {
    on_exit = function(_, code)
      self.event_reader:kill()
      local events = self.event_reader:wait(1000)

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end
      on_exit(code, chosen_files, events)
    end,
  })

  self.event_reader:start()

  return self
end

return YaziProcess
