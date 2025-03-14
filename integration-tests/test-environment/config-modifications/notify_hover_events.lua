---@module "yazi"

require("yazi")

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziDDSHover",
  -- see `:help event-args`
  ---@param event {data: YaziHoverEvent}
  callback = function(event)
    -- selene: allow(global_usage)
    _G.yazi_test_events = _G.yazi_test_events or {}
    -- selene: allow(global_usage)
    table.insert(
      _G.yazi_test_events,
      { "Just received a YaziDDSHover event!", event.data }
    )
  end,
})
