import assert from "assert"
import {
  isDirectorySelectedInYazi,
  isFileSelectedInYazi,
} from "./utils/yazi-utils"

describe("rename events with LSP support", () => {
  it("can rename a file with LSP support", () => {
    // When an LSP server is running, and a file is renamed in yazi, yazi.nvim
    // can use the LSP server to rename the file and all its references in the
    // project.
    cy.visit("/")
    cy.startNeovim({ filename: "lua-project/config.lua" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      // It takes a bit of time for the LSP server to start.
      //
      // This is a pretty hacky way to know when the LSP server is ready. It
      // shows an "unused" warning when it has started :)
      nvim
        .runLuaCode({ luaCode: `vim.lsp.get_clients({bufnr=0})` })
        .then((result) => {
          const clients = result.value
          assert(!clients)
        })
      nvim.waitForLuaCode({
        luaAssertion: `assert(#vim.diagnostic.get(0) > 0)`,
      })

      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open and display the footer
      cy.contains("NOR")

      isFileSelectedInYazi("config.lua")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")
      cy.typeIntoTerminal("q")

      // The LSP server asks for confirmation. Other LSPs don't seem to do
      // this, but it works...
      cy.contains("Do you want to modify the require path?")
      cy.contains("1: Modify")
      cy.typeIntoTerminal("1{enter}")
      cy.contains("Do you want to modify the require path?").should("not.exist")

      // go back to the init.lua file and verify the require path was updated
      nvim.runExCommand({ command: `edit %:h/init.lua` })
      cy.contains(`local config = require("config2")`)
    })
  })

  it("can rename a directory with LSP support", () => {
    // When an LSP server is running, and a directory that contains that file
    // is renamed in yazi, yazi.nvim should notify the LSP server to rename the
    // file and update all its references in the project.
    cy.visit("/")
    cy.startNeovim({ filename: "lua-project/init.lua" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains(`-- 609a3a37-42da-494d-908e-749d3aedca58`)

      // It takes a bit of time for the LSP server to start.
      //
      // This is a pretty hacky way to know when the LSP server is ready. It
      // shows an "unused" warning when it has started :)
      nvim
        .runLuaCode({ luaCode: `vim.lsp.get_clients({bufnr=0})` })
        .then((result) => {
          const clients = result.value
          assert(!clients)
        })
      nvim.waitForLuaCode({
        luaAssertion: `assert(#vim.diagnostic.get(0) > 0)`,
      })

      // make sure the require path is unmodified
      cy.contains(`local utils = require("utils.utils")`)

      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open and display the footer
      cy.contains("NOR")

      cy.typeIntoTerminal("gg")
      // the directory contents should be visible. This is how we know the
      // directory has been selected
      cy.contains("utils.lua")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")
      cy.typeIntoTerminal("q")
      cy.contains("NOR").should("not.exist")

      // The LSP server asks for confirmation. Other LSPs don't seem to do
      // this, but it works...
      cy.contains("Do you want to modify the require path?")
      cy.contains("1: Modify")
      cy.typeIntoTerminal("1{enter}")
      cy.contains("Do you want to modify the require path?").should("not.exist")

      // the require path should have been updated
      cy.contains(`local utils = require("utils2.utils")`)
    })
  })
})

describe("move events with LSP support", () => {
  it("can move a file with LSP support", () => {
    // This is like renaming, but moving the file. The result is the same, but
    // yazi sends a different event (move vs rename) for it.
    cy.visit("/")
    cy.startNeovim({ filename: "lua-project/config.lua" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      // It takes a bit of time for the LSP server to start.
      //
      // This is a pretty hacky way to know when the LSP server is ready. It
      // shows an "unused" warning when it has started :)
      nvim
        .runLuaCode({ luaCode: `vim.lsp.get_clients({bufnr=0})` })
        .then((result) => {
          const clients = result.value
          assert(!clients)
        })
      nvim.waitForLuaCode({
        luaAssertion: `assert(#vim.diagnostic.get(0) > 0)`,
      })

      nvim.runBlockingShellCommand({
        command: "mkdir newdir",
        cwdRelative: "lua-project",
      })
      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open and display the footer
      cy.contains("NOR")

      isFileSelectedInYazi("config.lua")
      // start the move command
      cy.typeIntoTerminal("x")

      // move to the new directory and enter it
      cy.typeIntoTerminal("gg")
      isDirectorySelectedInYazi("newdir")
      cy.typeIntoTerminal("l")

      // paste the file in and quit. This should trigger the lsp move operation.
      cy.typeIntoTerminal("p")
      cy.typeIntoTerminal("q")

      // The LSP server should be asking for confirmation
      cy.contains("Do you want to modify the require path?")
      cy.contains("1: Modify")
      cy.typeIntoTerminal("1{enter}")
      cy.contains("Do you want to modify the require path?").should("not.exist")

      // go back to the init.lua file and verify the require path was updated
      nvim.runExCommand({ command: `edit %:h/../init.lua` })
      cy.contains(`local config = require("newdir.config")`)
    })
  })
})
