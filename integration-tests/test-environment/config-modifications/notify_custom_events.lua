---@module "yazi"

require("yazi").config.forwarded_dds_events =
  { "MyMessageNoData", "MyMessageWithData" }

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziDDSCustom",
  -- see `:help event-args`
  ---@param event yazi.AutoCmdEvent
  callback = function(event)
    -- printing the messages will allow seeing them with `:messages` in tests
    print(vim.inspect({
      string.format(
        "Just received a YaziDDSCustom event '%s'!",
        event.data.type
      ),
      event.data,
    }))
  end,
})
