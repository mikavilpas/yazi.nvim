describe("opening directories", () => {
  it("can open a directory when starting with `neovim .`", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({
      // `neovim .` specifies to open the current directory when neovim is
      // starting
      filename: ".",
    }).then((dir) => {
      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["test-setup.lua"].name)
    })
  })

  it("can open a directory with `:edit .`", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["initial-file.txt"].name)

      // open the current directory using a command
      cy.typeIntoTerminal(":edit .{enter}")

      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["test-setup.lua"].name)
    })
  })
})
