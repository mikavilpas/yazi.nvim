describe("the healthcheck", () => {
  it("can run the :healthcheck for yazi.nvim", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim()

    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")

    cy.typeIntoTerminal(":checkhealth yazi{enter}")

    // the `yazi` application should be found successfully
    cy.contains("OK yazi")
  })
})
