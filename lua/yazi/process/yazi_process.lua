---@module "plenary.path"

local YaProcess = require("yazi.process.ya_process")
local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziProcessApi = require("yazi.process.yazi_process_api")

---@class YaziProcess
---@field public api YaziProcessApi
---@field public yazi_job_id integer
---@field public ya_process YaProcess "The process that reads events from yazi"
local YaziProcess = {}

---@diagnostic disable-next-line: inject-field
YaziProcess.__index = YaziProcess

---@param config YaziConfig
---@param paths Path[]
---@param on_exit fun(code: integer, selected_files: string[], events: YaziEvent[], hovered_url: string | nil)
function YaziProcess:start(config, paths, on_exit)
  os.remove(config.chosen_file_path)

  -- The YAZI_ID of the yazi process, used to uniquely identify this specific
  -- instance, so that we can communicate with it specifically, instead of
  -- possibly multiple other yazis that are running on this computer.
  local yazi_id = string.format("%.0f", vim.uv.hrtime())
  self.api = YaziProcessApi.new(config, yazi_id)

  self.ya_process = YaProcess.new(config, yazi_id)

  local yazi_cmd = self.ya_process:get_yazi_command(paths)
  Log:debug(string.format("Opening yazi with the command: (%s).", yazi_cmd))

  self.yazi_job_id = vim.fn.termopen(yazi_cmd, {
    on_exit = function(_, code)
      self.ya_process:kill()
      local events = self.ya_process:wait(1000)

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end
      on_exit(code, chosen_files, events, self.ya_process.hovered_url)
    end,
  })

  self.ya_process:start()

  return self
end

return YaziProcess
