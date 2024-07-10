---@module "plenary.path"

local M = {}

---@class FakeYaziArguments
---@field code integer
---@field selected_files string[]
---@field events YaziEvent[]
M.mocks = {}

---@param arguments { code?: integer, selected_files?: string[], events?: YaziEvent[]}
function M.setup_created_instances_to_instantly_exit(arguments)
  M.mocks.code = arguments.code or 0
  M.mocks.selected_files = arguments.selected_files or {}
  M.mocks.events = arguments.events or {}
end

-- Fake yazi process that instantly exits with the mocked data that was set up
-- before.
---@param on_exit fun(code: integer, selected_files: string[], events: YaziEvent[])
---@diagnostic disable-next-line: unused-local
function M:start(_, _, on_exit)
  on_exit(M.mocks.code, M.mocks.selected_files, M.mocks.events)
end

return M
