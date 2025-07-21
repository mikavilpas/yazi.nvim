---@module "yazi"

do
  local config = require("yazi").config
  assert(config, "yazi.config is not set")

  config.forwarded_dds_events = vim.tbl_extend(
    "force",
    config.forwarded_dds_events or {},
    { "MyMessageNoData", "MyChangeWorkingDirectoryCommand" }
  )
end

-- selene: allow(global_usage)
_G.YaziTestDDSCustomEvents = {}

vim.api.nvim_create_autocmd("User", {
  pattern = "YaziDDSCustom",
  -- see `:help event-args`
  ---@param event yazi.AutoCmdEvent
  callback = function(event)
    -- selene: allow(global_usage)
    table.insert(_G.YaziTestDDSCustomEvents, event)
    -- printing the messages will allow seeing them with `:messages` in tests
    print(vim.inspect({
      string.format(
        "Just received a YaziDDSCustom event '%s'!",
        event.data.type
      ),
      event.data,
    }))

    if event.data.type == "MyChangeWorkingDirectoryCommand" then
      local json = vim.json.decode(event.data.raw_data)
      local selected_file = assert(json.selected_file)

      local new_cwd = vim.fn.fnamemodify(selected_file, ":p:h")

      -- change Neovim's current working directory
      vim.cmd("cd " .. new_cwd)
    end
  end,
})
