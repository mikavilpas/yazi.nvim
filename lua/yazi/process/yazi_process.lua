---@module "plenary.path"

local YaProcess = require("yazi.process.ya_process")
local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziProcessApi = require("yazi.process.yazi_process_api")
local plenary_path = require("plenary.path")

---@class YaziProcess
---@field public api YaziProcessApi
---@field public yazi_job_id integer
---@field public ya_process YaProcess "The process that reads events from yazi"
local YaziProcess = {}

---@diagnostic disable-next-line: inject-field
YaziProcess.__index = YaziProcess

---@class yazi.Callbacks
---@field on_exit fun(code: integer, selected_files: string[], hovered_url: string | nil, last_cwd: Path | nil, context: YaziActiveContext)
---@field on_ya_first_event fun(api: YaziProcessApi)

---@param config YaziConfig
---@param paths Path[]
---@param callbacks yazi.Callbacks
---@return YaziProcess, YaziActiveContext
function YaziProcess:start(config, paths, callbacks)
  os.remove(config.chosen_file_path)

  -- The YAZI_ID of the yazi process, used to uniquely identify this specific
  -- instance, so that we can communicate with it specifically, instead of
  -- possibly multiple other yazis that are running on this computer.
  local yazi_id = string.format("%.0f", vim.uv.hrtime())
  self.api = YaziProcessApi.new(config, yazi_id)

  self.ya_process = YaProcess.new(config, yazi_id, function()
    callbacks.on_ya_first_event(self.api)
  end, assert(paths[1]).filename)

  local yazi_cmd = self.ya_process:get_yazi_command(paths)
  Log:debug(
    string.format("Opening yazi with the command: (%s).", vim.inspect(yazi_cmd))
  )

  ---@type YaziActiveContext
  local context = {
    api = self.api,
    ya_process = self.ya_process,
    yazi_job_id = self.yazi_job_id,
    input_path = paths[1],
  }

  self.yazi_job_id = vim.fn.jobstart(yazi_cmd, {
    term = true,
    env = {
      -- expose NVIM_CWD so that yazi keybindings can use it to offer basic
      -- neovim specific functionality
      NVIM_CWD = vim.uv.cwd(),
      YAZI_CONFIG_HOME = config.config_home,
    },
    on_exit = function(_, code)
      self.ya_process:kill_and_wait(1000)

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end

      local last_directory = nil
      if
        config.future_features.use_cwd_file == true
        and utils.file_exists(config.cwd_file_path) == true
      then
        last_directory =
          plenary_path:new(vim.fn.readfile(config.cwd_file_path)[1])
        require("yazi.log"):debug(
          string.format(
            "using cwd found from the cwd_file_path: '%s'",
            last_directory
          )
        )
      elseif self.ya_process.cwd ~= nil then
        last_directory = plenary_path:new(self.ya_process.cwd)
        require("yazi.log"):debug(
          string.format("using ya process cwd: '%s'", self.ya_process.cwd)
        ) --[[@as Path]]
      end

      callbacks.on_exit(
        code,
        chosen_files,
        self.ya_process.hovered_url,
        last_directory,
        context
      )
    end,
  })

  self.ya_process:start(context)

  return self, context
end

return YaziProcess
