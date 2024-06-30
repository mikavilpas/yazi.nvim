describe("opening files", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
    cy.startNeovim()
    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")
  })

  it("can display yazi in a floating terminal", () => {
    cy.typeIntoTerminal("{upArrow}")

    // yazi should now be visible, showing the names of adjacent files
    cy.contains("test-setup.lua") // an adjacent file
  })

  it("can open a file that was selected in yazi", () => {
    cy.typeIntoTerminal("{upArrow}")
    cy.contains("file.txt") // an adjacent file

    // search for the file in yazi. This focuses the file in yazi
    cy.typeIntoTerminal("gg/file.txt{enter}")
    cy.typeIntoTerminal("{enter}")

    // the file content should now be visible
    cy.contains("Hello 👋")
  })

  it("can open a file in a vertical split", () => {
    cy.typeIntoTerminal("{upArrow}")
    cy.typeIntoTerminal("j{control+v}")

    // the file path must be visible at the bottom
    cy.contains("test-environment/test-setup.lua")
    cy.contains("initial-file.txt")
  })

  it("can open a file in a horizontal split", () => {
    cy.typeIntoTerminal("{upArrow}")
    cy.typeIntoTerminal("j{control+x}")

    // the file path must be visible at the bottom
    cy.contains("test-environment/test-setup.lua")
    cy.contains("initial-file.txt")
  })

  it("can send file names to the quickfix list", () => {
    cy.typeIntoTerminal("{upArrow}")
    cy.typeIntoTerminal("{control+a}{enter}")

    // items in the quickfix list should now be visible
    cy.contains("file.txt||")
    cy.contains("initial-file.txt||")
  })

  it("can grep in the current directory", () => {
    cy.typeIntoTerminal("{upArrow}")
    cy.typeIntoTerminal("{control+s}")

    // telescope should now be visible
    cy.contains("Grep in")
    cy.contains("Grep Preview")
  })
})
