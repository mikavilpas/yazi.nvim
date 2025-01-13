import { isFileSelectedInYazi } from "./utils/yazi-utils"

describe("rename events with LSP support", () => {
  it("can rename a file with LSP support", () => {
    // When an LSP server is running, and a file is renamed in yazi, yazi.nvim
    // can use the LSP server to rename the file and all its references in the
    // project.
    cy.visit("/")
    cy.startNeovim({ filename: "lua-project/config.lua" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      // This is a pretty hacky way to know when the LSP server is ready. It
      // shows an "unused" warning when it has started :)
      //
      // It takes a bit of time for the LSP server to start
      cy.contains("Unused local `ready`.", { timeout: 15_000 })
      // cy.typeIntoTerminal(":LspInfo{enter}")
      // cy.pause()

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
})
