---@diagnostic disable: lowercase-global
rockspec_format = '3.0'
package = 'yazi.nvim'
version = 'scm-1'
source = {
  url = 'git+https://github.com/mikavilpas/yazi.nvim',
}
dependencies = {
  'lua >= 5.1',
  -- Add runtime dependencies here
  -- e.g. "plenary.nvim",
  'plenary.nvim',

  -- https://github.com/akinsho/bufferline.nvim
  -- https://luarocks.org/modules/neorocks/bufferline.nvim
  'bufferline.nvim',

  'nvim-lsp-file-operations >= scm',
}
test_dependencies = {
  'nlua',
  'plenary.nvim',
}
build = {
  type = 'builtin',
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}
