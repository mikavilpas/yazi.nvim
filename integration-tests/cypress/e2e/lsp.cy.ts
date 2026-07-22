import type { RunLuaCodeOutput } from "@tui-sandbox/library/server"

import type { NeovimContext } from "../support/tui-sandbox.ts"
import { assertYaziIsReady, isDirectorySelectedInYazi, isFileSelectedInYazi } from "./utils/yazi-utils.js"

/** It takes a bit of time for the LSP server to start. Wait until it's ready. */
const waitForEmmyluaLsReady = (nvim: NeovimContext): Cypress.Chainable<RunLuaCodeOutput> =>
  // It takes a bit of time for the LSP server to start.
  nvim.waitForLuaCode({
    luaAssertion: `
      local emmylua_ls = vim.lsp.get_clients({name="emmylua_ls"})[1]
      assert(emmylua_ls.initialized)
      `,
  })

const waitConfirmRenameDialog = (): void => {
  cy.contains("Do you want to modify the require path?")
  cy.typeIntoTerminal("{enter}")
  cy.contains("Do you want to modify the require path?").should("not.exist")
}

describe("rename events with LSP support", () => {
  it("can rename a file with LSP support", () => {
    // When an LSP server is running, and a file is renamed in yazi, yazi.nvim
    // can use the LSP server to rename the file and all its references in the
    // project.
    cy.visit("/")
    cy.startNeovim({
      filename: "lua-project/lua/config.lua",
      startupScriptModifications: ["add_yazi_context_assertions.lua"],
      NVIM_APPNAME: "nvim_integrations",
    }).then(nvim => {
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      waitForEmmyluaLsReady(nvim)

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      isFileSelectedInYazi("config.lua")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")
      // wait for emmylua-analyzer-rust to show up a confirmation dialog
      waitConfirmRenameDialog()
      cy.typeIntoTerminal("q")
      cy.contains("NOR").should("not.exist") // yazi should close

      // go back to the init.lua file and verify the require path was updated
      nvim.runExCommand({ command: `edit %:h/init.lua` })
      cy.contains(`local config = require('config2')`)
    })
  })

  it("can rename a directory with LSP support", () => {
    // When an LSP server is running, and a directory that contains that file
    // is renamed in yazi, yazi.nvim should notify the LSP server to rename the
    // file and update all its references in the project.
    cy.visit("/")
    cy.startNeovim({
      filename: "lua-project/lua/init.lua",
      startupScriptModifications: ["add_yazi_context_assertions.lua"],
      NVIM_APPNAME: "nvim_integrations",
    }).then(nvim => {
      // wait until text on the start screen is visible
      cy.contains(`-- 609a3a37-42da-494d-908e-749d3aedca58`)

      waitForEmmyluaLsReady(nvim)

      // make sure the require path is unmodified
      cy.contains(`local utils = require("utils.utils")`)

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      cy.typeIntoTerminal("gg")
      // the directory contents should be visible. This is how we know the
      // directory has been selected
      cy.contains("utils.lua")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")
      waitConfirmRenameDialog()
      cy.typeIntoTerminal("q")

      // the require path should have been updated
      cy.contains(`local utils = require('utils2.utils')`)
    })
  })
})

describe("move events with LSP support", () => {
  it("can move a file with LSP support", () => {
    // This is like renaming, but moving the file. The result is the same, but
    // yazi sends a different event (move vs rename) for it.
    cy.visit("/")
    cy.startNeovim({
      filename: "lua-project/lua/config.lua",
      startupScriptModifications: ["add_yazi_context_assertions.lua"],
      NVIM_APPNAME: "nvim_integrations",
    }).then(nvim => {
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      waitForEmmyluaLsReady(nvim)

      nvim.runBlockingShellCommand({
        command: "mkdir newdir",
        cwdRelative: "lua-project/lua",
      })
      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open and display the footer
      assertYaziIsReady(nvim)

      isFileSelectedInYazi("config.lua")
      // start the move command
      cy.typeIntoTerminal("x")

      // move to the new directory and enter it
      cy.typeIntoTerminal("gg")
      isDirectorySelectedInYazi("newdir")
      cy.typeIntoTerminal("l")

      // paste the file in and quit. This should trigger the lsp move operation.
      cy.typeIntoTerminal("p")
      waitConfirmRenameDialog()
      cy.typeIntoTerminal("q")

      // go back to the init.lua file and verify the require path was updated
      nvim.runExCommand({ command: `edit %:h/../init.lua` })
      cy.contains(`local config = require('newdir.config')`)
    })
  })
})
