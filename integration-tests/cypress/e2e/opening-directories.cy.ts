describe("opening directories", () => {
  it("can open a directory when starting with `neovim .`", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({
      // `neovim .` specifies to open the current directory when neovim is
      // starting
      filename: ".",
    })

    // yazi should now be visible, showing the names of adjacent files
    cy.contains("file.txt")
    cy.contains("initial-file.txt")
  })
})
