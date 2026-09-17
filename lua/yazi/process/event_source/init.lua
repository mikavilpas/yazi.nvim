--- An event source is the transport that carries yazi's
--- [DDS](https://yazi-rs.github.io/docs/dds) events to yazi.nvim.
---
--- Everything downstream of the transport - parsing the lines, tracking the
--- hovered file, renaming buffers - is the same either way and lives in
--- `YaProcess`.
---
--- The methods are called in this order:
---
--- 1. `open()`, before yazi is started, so the source can set up whatever the
---    yazi command line has to refer to
--- 2. `yazi_arguments()` and `environment()`, to build that command line
--- 3. `terminal_command()`, to wrap it in whatever Neovim should actually run
--- 4. `start()`, once yazi is running
--- 5. `close()`, once yazi has exited
---
---@class yazi.EventSource
---@field name string # for logging and test assertions
---@field id fun(self: yazi.EventSource): string # for logging and test assertions
---@field open fun(self: yazi.EventSource, on_lines: fun(lines: string[])): boolean, string? # acquire the resources the yazi command line refers to. Returns `false` and a message when the source cannot be used.
---@field yazi_arguments fun(self: yazi.EventSource): string[] # extra arguments yazi itself must be started with
---@field terminal_command fun(self: yazi.EventSource, yazi_command: string[]): string[] # the command Neovim runs in its terminal, given the yazi command line
---@field environment fun(self: yazi.EventSource): table<string, string> # extra environment variables for that command
---@field start fun(self: yazi.EventSource): nil # begin receiving events, now that yazi is running
---@field close fun(self: yazi.EventSource, timeout: integer): nil
---@field is_listening fun(self: yazi.EventSource): boolean
---@field is_ready_signal fun(self: yazi.EventSource, event: YaziEvent): boolean # whether this event proves that yazi is up and reporting

local M = {}

---The DDS event kinds yazi.nvim needs in order to keep Neovim in sync with
---what happens inside yazi. These are the shared kinds between all sources.
---@param config YaziConfig
---@return string[] kinds, table<string, boolean> forwarded_event_kinds
function M.event_kinds(config)
  local kinds = {
    "rename",
    "delete",
    "trash",
    "move",
    "cd",
    "hover",
    "bulk",
    "bulk-rename",
  }

  if config.future_features.yazi_plugin_keymaps ~= nil then
    kinds[#kinds + 1] = "yazi-nvim"
  end

  ---@type table<string, boolean>
  local forwarded_event_kinds = {}
  if config.forwarded_dds_events ~= nil then
    for _, event_kind in ipairs(config.forwarded_dds_events) do
      kinds[#kinds + 1] = event_kind
      forwarded_event_kinds[event_kind] = true
    end
  end

  return kinds, forwarded_event_kinds
end

---@param config YaziConfig
---@param yazi_id string
---@return yazi.EventSource
function M.create(config, yazi_id)
  if config.future_features.use_local_events == true then
    return require("yazi.process.event_source.local_events").new(
      config,
      yazi_id
    )
  end

  return require("yazi.process.event_source.ya_sub").new(config, yazi_id)
end

---@param config YaziConfig
---@param yazi_id string
---@return yazi.EventSource
function M.create_fallback(config, yazi_id)
  return require("yazi.process.event_source.ya_sub").new(config, yazi_id)
end

return M
