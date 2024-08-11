---@module "yazi"

require("yazi")

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziDDSHover",
  -- see `:help event-args`
  ---@param event {data: YaziHoverEvent}
  callback = function(event)
    -- printing the messages will allow seeing them with `:messages`
    print(vim.inspect({ "Just received a YaziDDSHover event!", event.data }))
  end,
})
