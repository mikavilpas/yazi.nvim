---@module "plenary.path"

local M = {}

---@class FakeYaziArguments
---@field code integer
---@field selected_files string[]
---@field api YaziProcessApi
---@field hovered_url string | nil
---@field last_cwd Path | nil
M.mocks = {}

---@param arguments { code?: integer, selected_files?: string[], events?: YaziEvent[], api: YaziProcessApi, hovered_url?: string | nil, last_cwd?: Path | nil }
function M.setup_created_instances_to_instantly_exit(arguments)
  M.mocks.code = arguments.code or 0
  M.mocks.selected_files = arguments.selected_files or {}
  M.api = arguments.api or {}
  M.mocks.hovered_url = arguments.hovered_url or nil
  M.mocks.last_cwd = arguments.last_cwd or nil
end

-- Fake yazi process that instantly exits with the mocked data that was set up
-- before.
---@param callbacks yazi.Callbacks
---@diagnostic disable-next-line: unused-local
function M:start(_, _, callbacks)
  ---@type YaziActiveContext
  callbacks.on_exit(
    M.mocks.code,
    M.mocks.selected_files,
    M.mocks.hovered_url,
    M.mocks.last_cwd,
    ---@diagnostic disable-next-line: missing-fields
    {} --[[@as YaziActiveContext]]
  )
  return self
end

return M
