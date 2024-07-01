describe("opening files", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  it("can display yazi in a floating terminal", () => {
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")

      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["test.lua"].name) // an adjacent file
    })
  })

  it("can open a file that was selected in yazi", () => {
    cy.startNeovim().then((dir) => {
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["file.txt"].name)

      // search for the file in yazi. This focuses the file in yazi
      cy.typeIntoTerminal("gg/file.txt{enter}")
      cy.typeIntoTerminal("{enter}")

      // the file content should now be visible
      cy.contains("Hello 👋")
    })
  })

  it("can open a file in a vertical split", () => {
    cy.startNeovim().then((dir) => {
      cy.typeIntoTerminal("{upArrow}")
      cy.typeIntoTerminal("/test.lua{enter}")
      cy.typeIntoTerminal("{control+v}")

      // the file path must be visible at the bottom
      cy.contains(dir.contents["test.lua"].name)
      cy.contains(dir.contents["initial-file.txt"].name)
    })
  })

  it("can open a file in a horizontal split", () => {
    cy.startNeovim().then((dir) => {
      cy.typeIntoTerminal("{upArrow}")
      cy.typeIntoTerminal("/test.lua{enter}")
      cy.typeIntoTerminal("{control+x}")

      // the file path must be visible at the bottom
      cy.contains(dir.contents["test.lua"].name)
      cy.contains(dir.contents["initial-file.txt"].name)
    })
  })

  it("can send file names to the quickfix list", () => {
    cy.startNeovim().then((dir) => {
      cy.typeIntoTerminal("{upArrow}")
      cy.typeIntoTerminal("{control+a}{enter}")

      // items in the quickfix list should now be visible
      cy.contains(`${dir.contents["file.txt"].name}||`)
      cy.contains(`${dir.contents["initial-file.txt"].name}||`)
    })
  })

  it("can open files with complex characters in their name", () => {
    cy.startNeovim().then((dir) => {
      cy.typeIntoTerminal("{upArrow}")

      // enter the routes/ directory
      cy.typeIntoTerminal("/routes{enter}")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(dir.contents["routes/posts.$postId/route.tsx"].name) // file in the directory

      // enter routes/posts.$postId/
      cy.typeIntoTerminal("{rightArrow}")

      // select route.tsx
      cy.typeIntoTerminal(
        `/${dir.contents["routes/posts.$postId/route.tsx"].name}{enter}`,
      )

      // open the file
      cy.typeIntoTerminal("{enter}")

      // close yazi just to be sure the file preview is not found instead
      cy.get(
        dir.contents["routes/posts.$postId/adjacent-file.tsx"].name,
      ).should("not.exist")

      // the file contents should now be visible
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")
    })
  })
})
