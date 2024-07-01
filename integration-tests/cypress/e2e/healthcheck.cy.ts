import { startNeovimWithYa } from "./using-ya-to-read-events/startNeovimWithYa"

describe("the healthcheck", () => {
  it("can run the :healthcheck for yazi.nvim", () => {
    cy.visit("http://localhost:5173")
    startNeovimWithYa()

    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")

    cy.typeIntoTerminal(":checkhealth yazi{enter}")

    // the `yazi` and `ya` applications should be found successfully
    cy.contains("Found yazi version 0.2.5")
    cy.contains("Found ya version 0.2.5")
    cy.contains("OK yazi")
  })
})
