-- selene: allow(unused_variable)
function Yazi_reveal_path(path)
  local yazi = require("yazi")

  ---@type YaziActiveContext | nil
  local context = yazi.active_contexts:peek()

  local Log = require("yazi.log")
  if context then
    Log:debug("Revealing path in yazi context: " .. vim.inspect(path))

    require("yazi.process.retry").retry({
      description = "Revealing path in yazi context",
      delay = 50,
      retries = 10,
      action = function()
        local job = context.api:reveal(path)
        local completed = job:wait(1000)

        assert(completed.code == 0)
        return nil
      end,
    })
  else
    Log:debug("No active yazi context found")
  end
end

print("Yazi: Loaded custom command to reveal a file")
