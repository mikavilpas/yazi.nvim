---@module "plenary.path"

local YaProcess = require("yazi.process.ya_process")
local Log = require("yazi.log")
local utils = require("yazi.utils")
local YaziProcessApi = require("yazi.process.yazi_process_api")
local plenary_path = require("plenary.path")
local uv = vim.uv or vim.loop

local YaziProcess = {}
YaziProcess.__index = YaziProcess

---@param config YaziConfig
---@param paths Path[]
---@param callbacks yazi.Callbacks
---@return YaziProcess, YaziActiveContext
function YaziProcess:start(config, paths, callbacks)
  os.remove(config.chosen_file_path)

  local yazi_id = string.format("%.0f", uv.hrtime())
  self.api = YaziProcessApi.new(config, yazi_id)

  self.ya_process = YaProcess.new(config, yazi_id, function()
    callbacks.on_ya_first_event(self.api)
  end, assert(paths[1]).filename)

  -- 1. Spin up a dynamic local TCP server to receive events with zero disk I/O
  local tcp_server = uv.new_tcp()
  tcp_server:bind("127.0.0.1", 0)
  local port = tcp_server:getsockname().port

  self.active_clients = {} -- Keep track to close them cleanly later

  -- Find the static wrapper script dynamically based on plugin location
  local script_path = debug.getinfo(1).source:match("@(.*)$")
  local wrapper_path = vim.fn.fnamemodify(script_path, ":h") .. "/wrapper.lua"

  local raw_yazi_cmd = self.ya_process:get_yazi_command(paths)
  local yazi_exe = table.remove(raw_yazi_cmd, 1)
  
  -- Pass the port to the wrapper as the first argument
  local yazi_cmd = { vim.v.progpath, "-l", wrapper_path, tostring(port), yazi_exe }
  for _, arg in ipairs(raw_yazi_cmd) do
    table.insert(yazi_cmd, arg)
  end

  -- Pre-declare context so it can be captured by the TCP callback below
  ---@type YaziActiveContext
  local context = {
    api = self.api,
    ya_process = self.ya_process,
    yazi_job_id = nil, -- Will be updated after jobstart
    input_path = paths[1],
  }

  tcp_server:listen(128, function(err)
    if err then return end
    local client = uv.new_tcp()
    tcp_server:accept(client)
    table.insert(self.active_clients, client)

    client:read_start(function(read_err, chunk)
      if read_err or not chunk then
        client:close()
        return
      end
      -- Push the data instantly to the main thread
      vim.schedule(function()
        if self.ya_process and context then
          self.ya_process:receive_chunk(chunk, context)
        end
      end)
    end)
  end)

  local env = {
    NVIM_CWD = uv.cwd(),
    YAZI_CONFIG_HOME = config.config_home,
    YAZI_NVIM_ID = yazi_id,
  }

  if config.future_features.yazi_plugin_keymaps ~= nil then
    local plugin_keymaps = require("yazi.plugin_keymaps")
    env[plugin_keymaps.env_var] = plugin_keymaps.serialize(config.future_features.yazi_plugin_keymaps)
  end

  self.yazi_job_id = vim.fn.jobstart(yazi_cmd, {
    term = true,
    env = env,
    on_exit = function(_, code)
      self.ya_process:kill_and_wait(1000)
      
      -- Close all active client connections
      for _, client in ipairs(self.active_clients or {}) do
        if not client:is_closing() then client:close() end
      end
      
      -- Close the server
      if tcp_server and not tcp_server:is_closing() then
        tcp_server:close()
      end

      local chosen_files = {}
      if utils.file_exists(config.chosen_file_path) == true then
        chosen_files = vim.fn.readfile(config.chosen_file_path)
      end

      local last_directory = nil
      if config.future_features.use_cwd_file == true and utils.file_exists(config.cwd_file_path) == true then
        last_directory = plenary_path:new(vim.fn.readfile(config.cwd_file_path)[1])
      elseif self.ya_process.cwd ~= nil then
        last_directory = plenary_path:new(self.ya_process.cwd)
      end

      callbacks.on_exit(code, chosen_files, self.ya_process.hovered_url, last_directory, context)
    end,
  })

  -- Update context with the active job ID now that it has been created
  context.yazi_job_id = self.yazi_job_id
  self.ya_process:start(context)

  return self, context
end

return YaziProcess