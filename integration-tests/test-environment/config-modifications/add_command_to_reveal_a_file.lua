-- selene: allow(unused_variable)
function Yazi_reveal_path(path)
  local yazi = require("yazi")

  ---@type YaziActiveContext | nil
  local context = yazi.active_contexts:peek()

  local Log = require("yazi.log")
  if context then
    Log:debug("Revealing path in yazi context: " .. vim.inspect(path))
    context.api:reveal(path)
  else
    Log:debug("No active yazi context found")
  end
end

print("Yazi: Loaded custom command to reveal a file")
