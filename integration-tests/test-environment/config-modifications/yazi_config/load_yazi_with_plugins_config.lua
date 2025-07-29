-- NOTE the key-event.yazi plugin must be symlinked to the
-- ~/.config/yazi_with_plugins/plugins/ folder. In the integration-tests environment, this
-- can be done using `:Lazy! build yazi.nvim`

require("yazi").setup({
  config_home = vim.fs.normalize("~/.config/yazi_with_plugins/"),
})

require("yazi.log"):debug(
  "Test notice: loading yazi with plugins configuration"
)
