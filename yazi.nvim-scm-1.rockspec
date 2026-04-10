---@diagnostic disable: lowercase-global
rockspec_format = "3.0"
package = "yazi.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/mikavilpas/yazi.nvim",
}
dependencies = {
  -- Add runtime dependencies here
}
test_dependencies = {
  "nlua",
}
build = {
  type = "builtin",
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}
