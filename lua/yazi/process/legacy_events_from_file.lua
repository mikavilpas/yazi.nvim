local utils = require("yazi.utils")

-- The legacy way of reading events. Reads events from a file in one go after
-- the `yazi` process exits.
---@class (exact) LegacyEventReadingFromEventFile
---@field private config YaziConfig
local LegacyEventReadingFromEventFile = {}
---@diagnostic disable-next-line: inject-field
LegacyEventReadingFromEventFile.__index = LegacyEventReadingFromEventFile

---@param config YaziConfig
function LegacyEventReadingFromEventFile:new(config)
  self.config = config
  return self
end

---@param path Path
function LegacyEventReadingFromEventFile:get_yazi_command(path)
  return string.format(
    'yazi %s --local-events "rename,delete,trash,move,cd" --chooser-file "%s" > "%s"',
    vim.fn.shellescape(path.filename),
    self.config.chosen_file_path,
    self.config.events_file_path
  )
end

function LegacyEventReadingFromEventFile:start()
  return self
end

function LegacyEventReadingFromEventFile:kill() end

function LegacyEventReadingFromEventFile:wait()
  return utils.read_events_file(self.config.events_file_path)
end

return LegacyEventReadingFromEventFile
