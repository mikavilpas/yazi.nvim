local plenary_path = require("plenary.path")

---@class (exact) yazi.Log
---@field level yazi.LogLevel
---@field path string
local Log = {}

--- The log levels are the same as for vim.log.levels
---@enum yazi.LogLevel
local log_levels = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  OFF = 5,
}

---@type yazi.LogLevel
Log.level = log_levels.OFF

---@return string
function Log:get_logfile_path()
  if vim.uv.os_environ().YAZI_NVIM_LOG_PATH then
    return vim.uv.os_environ().YAZI_NVIM_LOG_PATH
  end
  local ok, stdpath = pcall(vim.fn.stdpath, "log")
  if not ok then
    stdpath = vim.fn.stdpath("cache")
  end
  return plenary_path:new(stdpath, "yazi.log"):absolute()
end

Log.path = Log:get_logfile_path()

---@type file*? # the file handle for the log file
local file = nil

---@param level string
---@param message string
function Log:write_message(level, message)
  -- initialize if needed
  if not file then
    local logfile, err = io.open(self.path, "a+")
    file = logfile

    if not file then
      local err_msg = string.format('Failed to open log file at "%s"', err)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "yazi.nvim" })
    end
  end

  if file ~= nil then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local msg = string.format("[%s] %s %s", timestamp, level, message)
    file:write(msg .. "\n")
    file:flush()
  end
end

---@param level yazi.LogLevel
function Log:active_for_level(level)
  return self.level and self.level ~= log_levels.OFF and self.level <= level
end

---@param message string
function Log:debug(message)
  if self:active_for_level(log_levels.DEBUG) then
    self:write_message("DEBUG", message)
  end
end

return Log
