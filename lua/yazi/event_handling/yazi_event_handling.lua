-- This file is about handling events that are sent from yazi

local utils = require("yazi.utils")

local M = {}

---@param event YaziDeleteEvent | YaziTrashEvent
---@param config YaziConfig
function M.process_delete_event(event, config)
  local open_buffers = utils.get_open_buffers()

  ---@type RenameableBuffer[]
  local deleted_buffers = {}

  for _, buffer in ipairs(open_buffers) do
    for _, url in ipairs(event.data.urls) do
      if buffer:matches_exactly(url) or buffer:matches_parent(url) then
        vim.schedule(function()
          utils.bufdelete(
            config.integrations.bufdelete_implementation,
            buffer.bufnr
          )
          require("yazi.lsp.delete").file_deleted(buffer.path.filename)
        end)
      end
    end
  end

  return deleted_buffers
end

---@param rename_or_move_event YaziEventDataRenameOrMove
---@return RenameableBuffer[] "instructions for renaming the buffers (command pattern)"
function M.get_buffers_that_need_renaming_after_yazi_exited(
  rename_or_move_event
)
  local open_buffers = utils.get_open_buffers()

  ---@type table<integer, RenameableBuffer>
  local renamed_buffers = {}

  local event = rename_or_move_event
  for _, buffer in ipairs(open_buffers) do
    if buffer:matches_exactly(event.from) then
      buffer:rename(event.to)
      renamed_buffers[buffer.bufnr] = buffer
    elseif buffer:matches_parent(event.from) then
      buffer:rename_parent(event.from, event.to)
      renamed_buffers[buffer.bufnr] = buffer
    end
  end

  return vim.tbl_values(renamed_buffers)
end

---@param config YaziConfig
---@param event_data YaziEventDataRenameOrMove
local function handle_rename_move_bulk_event(config, event_data)
  local rename_instructions =
    M.get_buffers_that_need_renaming_after_yazi_exited(event_data)

  for _, instruction in ipairs(rename_instructions) do
    utils.rename_or_close_buffer(config, instruction)
  end
end

---@param event YaziEvent
---@param config YaziConfig
---@param context YaziActiveContext
function M.process_event_emitted_from_yazi(event, config, context)
  local lsp_rename = require("yazi.lsp.rename")

  if event.type == "rename" then
    ---@cast event YaziRenameEvent
    lsp_rename.file_renamed(event.data.from, event.data.to)

    handle_rename_move_bulk_event(config, event.data)
  elseif event.type == "move" then
    ---@type YaziMoveEvent
    local move_event = event

    for _, item in ipairs(move_event.data.items) do
      lsp_rename.file_renamed(item.from, item.to)

      handle_rename_move_bulk_event(config, item)
    end
  elseif event.type == "bulk" or event.type == "bulk-rename" then
    ---@cast event YaziBulkEvent
    for from, to in pairs(event.changes) do
      vim.schedule(function()
        lsp_rename.file_renamed(from, to)
        handle_rename_move_bulk_event(config, { from = from, to = to })
      end)
    end
  elseif event.type == "delete" or event.type == "trash" then
    ---@cast event YaziDeleteEvent | YaziTrashEvent
    M.process_delete_event(event, config)
  elseif event.type == "cycle-buffer" then
    require("yazi.log"):debug("YaziNvimCycleBufferEvent received")
    ---@cast event YaziNvimCycleBufferEvent
    require("yazi.keybinding_helpers").cycle_open_buffers(config, context)
  end
end

--- dispatch a keymap action that was triggered from inside yazi by the
--- `nvim.yazi` plugin.
---
---@class yazi.PluginKeymapPayload
---@field action string # the keymap action, e.g. "open_file_in_vertical_split"
---@field yazi_id? string # the id of the yazi instance that sent the event
---@field hovered? string # the currently hovered path, if any
---@field selected? string[] # the currently selected paths
---
---@param event YaziCustomDDSEvent
---@param expected_yazi_id string # only handle events from our own yazi instance
---@param config YaziConfig
---@param context YaziActiveContext
function M.process_plugin_keymap_event(event, expected_yazi_id, config, context)
  local Log = require("yazi.log")
  local keybinding_helpers = require("yazi.keybinding_helpers")

  local ok, payload = pcall(vim.json.decode, event.raw_data)
  if not ok or type(payload) ~= "table" then
    Log:debug(
      string.format(
        "Could not decode yazi-nvim event payload: %s",
        vim.inspect(event.raw_data)
      )
    )
    return
  end
  ---@cast payload yazi.PluginKeymapPayload

  -- The DDS bus is shared across all yazi instances on the system. Only react
  -- to events from our own yazi.
  if payload.yazi_id ~= nil and payload.yazi_id ~= expected_yazi_id then
    Log:debug(
      string.format(
        "Ignoring yazi-nvim event from a different yazi (%s, ours is %s)",
        vim.inspect(payload.yazi_id),
        expected_yazi_id
      )
    )
    return
  end

  Log:debug(
    string.format("Handling yazi-nvim plugin keymap event: %s", payload.action)
  )

  if payload.action == "open_file_in_vertical_split" then
    keybinding_helpers.open_file_in_vertical_split(config, context.api)
  elseif payload.action == "open_file_in_horizontal_split" then
    keybinding_helpers.open_file_in_horizontal_split(config, context.api)
  else
    Log:debug(
      string.format("Unknown yazi-nvim plugin action: %s", payload.action)
    )
  end
end

return M
