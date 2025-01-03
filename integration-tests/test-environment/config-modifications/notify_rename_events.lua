---@module "yazi"

require("yazi")

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziRenamedOrMoved",
  ---@param event {data: YaziNeovimEvent.YaziRenamedOrMovedData}
  callback = function(event)
    -- selene: allow(global_usage)
    _G.yazi_test_events = _G.yazi_test_events or {}
    -- selene: allow(global_usage)
    table.insert(_G.yazi_test_events, event)
  end,
})
