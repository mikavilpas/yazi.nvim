-- Integration with the key-event.yazi plugin, which is bundled with yazi.nvim.
local M = {}

M.is_setup_done = false

function M.setup_once()
  if M.is_setup_done then
    return
  end

  -- make yazi.nvim listen to and publish KeyEvent DDS events
  local config = require("yazi").config
  table.insert(config.forwarded_dds_events, "KeyEvent")

  vim.api.nvim_create_autocmd("User", {
    pattern = "YaziDDSCustom",
    ---@param event yazi.AutoCmdEvent
    callback = function(event)
      if event.data.type == "KeyEvent" then
        local json = vim.json.decode(event.data.raw_data)
        local key = assert(json.key)

        if key == "key-quit" then
          require("yazi.log"):debug(
            string.format(
              "Received key-quit, will cd neovim to '%s'",
              vim.inspect(assert(json.cwd))
            )
          )
          vim.cmd.cd(json.cwd)
        end
      end
    end,
  })

  M.is_setup_done = true
end

return M
