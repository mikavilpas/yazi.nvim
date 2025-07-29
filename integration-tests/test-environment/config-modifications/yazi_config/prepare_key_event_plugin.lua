-- NOTE the key-event.yazi plugin must be symlinked to the
-- ~/.config/yazi/plugins/ folder. In the integration-tests environment, this
-- can be done using `:Lazy! build yazi.nvim`

require("yazi").setup({
  integrations = {
    yazi_plugins = {
      key_event = true,
    },
  },
})
