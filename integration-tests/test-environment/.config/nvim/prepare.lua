-- This file defines how to set up Neovim's plugins and external applications
-- such as LSP servers and formatters.
--
-- They can be slow to install, which would make the tests slow (and they might
-- be flaky because of this). This is why this file can be executed before
-- starting the test run.

-- make sure the dependencies defined in ./init.lua are installed
vim.cmd("Lazy! sync")

-- Install an LSP server for use in end-to-end tests. Here, the server will be
-- put under the .repro/ directory, so it only needs to be installed once when
-- the entire test run is being started. The tests can reuse the LSP server
-- without re-downloading it.
--
-- The recommendation is to add a specific version to avoid issues in the
-- future
require("mason")
require("mason-lspconfig").setup({
  -- TODO why does automatic_installation not work?
  -- ensure_installed = { "lua_ls@3.13.5" },
  -- automatic_installation = true,
})

-- TODO this seems to report some minor error but it works after that. Should
-- clean this up, though.
vim.cmd("LspInstall lua_ls@3.13.5")
