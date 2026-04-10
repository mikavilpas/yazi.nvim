local M = {}

---@param target_file string
function M.create_test_file(target_file)
  local YaziPath = require("yazi.path")
  local file = io.open(target_file, "w") -- Open or create the file in write mode
  assert(file, "Failed to create file " .. target_file)
  if file then
    file:write("")
    file:close()
  end
  assert(YaziPath:new(target_file):exists())
  assert(YaziPath:new(target_file):is_file())
  assert(YaziPath:new(target_file):parent():is_dir())
end

return M
