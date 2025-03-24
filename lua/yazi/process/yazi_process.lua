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
---@field on_maybe_started fun(yazi_process: YaziProcess) # when yazi has been started. Note that it might not be ready and initialized yet. We don't have a way to detect this.
---@field on_exit fun(code: integer, selected_files: string[], events: YaziEvent[], hovered_url: string | nil, last_cwd: Path | nil)

---@param config YaziConfig
---@param paths Path[]
---@param callbacks yazi.Callbacks
function YaziProcess:start(config, paths, callbacks)
  os.remove(config.chosen_file_path)

  -- The YAZI_ID of the yazi process, used to uniquely identify this specific
  -- instance, so that we can communicate with it specifically, instead of
  -- possibly multiple other yazis that are running on this computer.
  local yazi_id = string.format("%.0f", vim.uv.hrtime())
  self.api = YaziProcessApi.new(config, yazi_id)

  self.ya_process = YaProcess.new(config, yazi_id)

  local yazi_cmd = self.ya_process:get_yazi_command(paths)
  Log:debug(string.format("Opening yazi with the command: (%s).", yazi_cmd))

  if not config.future_features.use_nvim_0_10_termopen then
    Log:debug("Using nvim-0.11 jobstart to start yazi.")
    self.yazi_job_id = vim.fn.jobstart(yazi_cmd, {
      term = true,
      env = {
        -- expose NVIM_CWD so that yazi keybindings can use it to offer basic
        -- neovim specific functionality
        NVIM_CWD = vim.uv.cwd(),
      },
      on_exit = function(_, code)
        self.ya_process:kill()
        local events = self.ya_process:wait(1000)

        local chosen_files = {}
        if utils.file_exists(config.chosen_file_path) == true then
          chosen_files = vim.fn.readfile(config.chosen_file_path)
        end

        local last_directory = nil
        if self.ya_process.cwd ~= nil then
          last_directory = plenary_path:new(self.ya_process.cwd) --[[@as Path]]
        end

        callbacks.on_exit(
          code,
          chosen_files,
          events,
          self.ya_process.hovered_url,
          last_directory
        )
      end,
    })
  else
    Log:debug("Using nvim-0.10 termopen to start yazi.")
    self.yazi_job_id =
      self:nvim_0_10_termopen(config, callbacks.on_exit, yazi_cmd)
  end

  self.ya_process:start()
  callbacks.on_maybe_started(self)

  return self
end

function YaziProcess:nvim_0_10_termopen(config, on_exit, yazi_cmd)
  return vim.fn.termopen(yazi_cmd, {
    env = {
      -- expose NVIM_CWD so that yazi keybindings can use it to offer basic
      -- neovim specific functionality
      NVIM_CWD = vim.uv.cwd(),
    },
    on_exit = function(_, code)
      self.ya_process:kill()
      local events = self.ya_process:wait(1000)

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end

      local last_directory = nil
      if self.ya_process.cwd ~= nil then
        last_directory = plenary_path:new(self.ya_process.cwd) --[[@as Path]]
      end

      on_exit(
        code,
        chosen_files,
        events,
        self.ya_process.hovered_url,
        last_directory
      )
    end,
  })
end

return YaziProcess
