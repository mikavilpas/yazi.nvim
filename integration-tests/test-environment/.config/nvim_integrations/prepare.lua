-- This file defines how to set up Neovim's plugins and external applications
-- such as LSP servers and formatters.
--
-- They can be slow to install, which would make the tests slow (and they might
-- be flaky because of this). This is why this file can be executed before
-- starting the test run.

-- make sure the dependencies defined in ./init.lua are installed
vim.cmd("Lazy! sync")

-- An LSP server has been installed for use in end-to-end tests with mise. It's
-- expected to be available in the environment.
assert(
  vim.fn.executable("emmylua_ls") == 1,
  "emmylua_ls should be available for nvim"
)
