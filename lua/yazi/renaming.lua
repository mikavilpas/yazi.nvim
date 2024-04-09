local RenameableBuffer = require('yazi.renameable_buffer')

local M = {}

---@param rename_events YaziEventDataRename[]
---@return RenameableBuffer[] "instructions for renaming the buffers (command pattern)"
function M.get_buffers_that_need_renaming_after_yazi_exited(rename_events)
  ---@type RenameableBuffer[]
  local open_buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path ~= '' and path ~= nil then
      local renameable_buffer = RenameableBuffer.new(bufnr, path)
      open_buffers[#open_buffers + 1] = renameable_buffer
    end
  end

  ---@type table<integer, RenameableBuffer>
  local renamed_buffers = {}

  for _, event in ipairs(rename_events) do
    for _, buffer in ipairs(open_buffers) do
      if buffer:matches_exactly(event.from) then
        buffer:rename(event.to)
        renamed_buffers[buffer.bufnr] = buffer
      elseif buffer:matches_parent(event.from) then
        buffer:rename_parent(event.from, event.to)
        renamed_buffers[buffer.bufnr] = buffer
      end
    end
  end

  return vim.tbl_values(renamed_buffers)
end

return M
