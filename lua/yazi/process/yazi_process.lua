---@module "plenary.path"

local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziProcessApi = require("yazi.process.yazi_process_api")
local plenary_path = require("plenary.path")
local YaziSessionHighlighter =
  require("yazi.buffer_highlighting.yazi_session_highlighter")

---@class YaziProcess
---@field public api YaziProcessApi
---@field public yazi_job_id integer
---@field public ya_process YaProcessSingleton "The process that reads events from yazi"
---@field private state YaziState # readonly
local YaziProcess = {}

---@diagnostic disable-next-line: inject-field
YaziProcess.__index = YaziProcess

---@class YaziState
---@field public yazi_id string
---@field public hovered_url? string "The path that is currently hovered over in this yazi."
---@field public cwd? string "The path that the yazi process is currently in."
---@field on_first_output? fun()
---@field on_event fun( event: YaziEvent)
---@field ready boolean

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

  local ya_process_singleton = require("yazi.process.ya_process_singleton")
  self.ya_process = ya_process_singleton.new(config, yazi_id)

  ---@type YaziActiveContext
  local context = {
    api = self.api,
    ya_process = self.ya_process.ya,
    highlighter = YaziSessionHighlighter.new(),
    yazi_job_id = self.yazi_job_id,
    input_path = assert(paths[1]),
    hovered_file = paths[1].filename,
    cwd = nil,
  }

  self.state = {
    yazi_id = yazi_id,
    hovered_url = paths[1].filename,
    cwd = nil,
    ready = false,
    on_first_output = function()
      callbacks.on_ya_first_event(self.api)
    end,
    on_event = function(event)
      local nvim_event_handling =
        require("yazi.event_handling.nvim_event_handling")

      -- handle events that are meant to be received by a yazi instance that
      -- yazi.nvim controls
      if event.type == "hover" then
        ---@cast event YaziHoverEvent
        Log:debug(
          string.format(
            "Changing the hovered url from %s to %s",
            self.state.hovered_url,
            event.url
          )
        )
        -- have to keep a copy of the state so that we don't have to expose
        -- YaziState. That might prevent garbage collection of the state in an
        -- error scenario - these is a test for this though.
        self.state.hovered_url = event.url
        context.hovered_file = event.url
        vim.schedule(function()
          context.highlighter:highlight_buffers_when_hovered(event.url, config)
          nvim_event_handling.emit("YaziDDSHover", event)
        end)
      elseif event.type == "cd" then
        ---@cast event YaziHoverEvent
        Log:debug(
          string.format(
            "Changing the cwd of yazi_id %s from %s to %s",
            event.yazi_id,
            self.state.cwd,
            event.url
          )
        )

        -- have to keep a copy of the state so that we don't have to expose
        -- YaziState. That might prevent garbage collection of the state in an
        -- error scenario - these is a test for this though.
        self.state.cwd = event.url
        context.cwd = event.url
      end
    end,
  }

  self.ya_process:register_yazi(self.state)

  local yazi_cmd = self.ya_process:get_yazi_command(yazi_id, paths)
  Log:debug(string.format("Opening yazi with the command: (%s).", yazi_cmd))

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
      context.highlighter:clear_highlights()

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end

      local last_directory = nil
      local state = context.ya_process.known_yazis[context.api.yazi_id]
      assert(
        state,
        "Yazi state should be set by the ya_process for yazi_id: "
          .. context.api.yazi_id
      )
      if state.cwd ~= nil then
        last_directory = plenary_path:new(state.cwd) --[[@as Path]]
      end

      callbacks.on_exit(
        code,
        chosen_files,
        state.hovered_url,
        last_directory,
        context
      )
    end,
  })

  self.ya_process:start()

  return self, context
end

return YaziProcess
