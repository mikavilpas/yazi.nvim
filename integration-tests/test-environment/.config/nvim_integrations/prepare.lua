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
require("mason-registry").refresh()

-- NOTE: installing mason packages seems to report errors in headless mode, but
-- it seems to install the package anyway
-- https://github.com/williamboman/mason.nvim/issues/960#issuecomment-1528081759
local command = require("mason.api.command")
command.MasonInstall({ "emmylua_ls" }, { version = "0.10.0" })
