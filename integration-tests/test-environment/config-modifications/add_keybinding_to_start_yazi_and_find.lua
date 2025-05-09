-- open yazi and immediately enter find mode ("Find next") in yazi
vim.keymap.set("n", "<leader>r", function()
  require("yazi").yazi({
    ---@diagnostic disable-next-line: missing-fields
    hooks = {
      on_yazi_ready = function(_, _, process_api)
        -- https://yazi-rs.github.io/docs/configuration/keymap/#manager.find
        process_api:emit_to_yazi({ "find", "--smart" })
      end,
    },
  })
end)
