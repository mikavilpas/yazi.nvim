import { startNeovimWithYa } from "./startNeovimWithYa"

describe("mouse support", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  it("can use grug-far.nvim to search and replace in the cwd", () => {
    startNeovimWithYa().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // open yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be showing adjacent files
      cy.contains(dir.contents["test-setup.lua"].name)

      // click outside of the yazi floating window. This should close it
      // because it's designed to close when it loses focus
      cy.contains("-- TERMINAL --").click()

      // clicking outside of the yazi window should close it, after which
      // Neovim should not be showing the TERMINAL buffer any longer
      cy.contains("-- TERMINAL --").should("not.exist")
    })
  })
})
