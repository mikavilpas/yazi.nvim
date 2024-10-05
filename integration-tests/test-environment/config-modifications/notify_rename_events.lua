---@module "yazi"

require("yazi")

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziRenamedOrMoved",
  ---@param event {data: YaziNeovimEvent.YaziRenamedOrMovedData}
  callback = function(event)
    -- printing the messages will allow seeing them with `:messages`
    print(
      vim.inspect({ "Just received a YaziRenamedOrMoved event!", event.data })
    )
  end,
})
