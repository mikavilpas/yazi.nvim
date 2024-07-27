import { startNeovimWithYa } from "./startNeovimWithYa"

describe("opening directories", () => {
  it("can open a directory when starting with `neovim .`", () => {
    cy.visit("http://localhost:5173")
    startNeovimWithYa({
      // `neovim .` specifies to open the current directory when neovim is
      // starting
      filename: ".",
    }).then((dir) => {
      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["test-setup.lua"].name)

      cy.typeIntoTerminal("{downArrow}")
    })
  })
})
