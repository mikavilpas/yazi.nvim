describe("change_cwd_on_exit when set to 'always'", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("changes the cwd to the last directory", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_set_change_cwd_on_exit_always.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.runExCommand({ command: "echo getcwd()" })
        .its("value")
        .should("not.eql", dir.rootPathAbsolute)

      // toggle yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible, showing other files
      cy.contains(dir.contents["file2.txt"].name)
      cy.typeIntoTerminal("q")
      cy.contains(dir.contents["file2.txt"].name).should("not.exist")

      cy.runExCommand({ command: "echo getcwd()" })
        .its("value")
        .should("eql", dir.rootPathAbsolute)
    })
  })
})
