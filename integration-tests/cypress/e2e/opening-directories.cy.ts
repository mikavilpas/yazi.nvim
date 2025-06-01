describe("opening directories", () => {
  it("can open a directory when starting with `neovim .`", () => {
    cy.visit("/")
    cy.startNeovim({
      // `neovim .` specifies to open the current directory when neovim is
      // starting
      filename: ".",
    }).then((nvim) => {
      // yazi should now be visible, showing the names of adjacent files
      cy.contains("-- TERMINAL --")
      cy.contains(nvim.dir.contents["file2.txt"].name)

      cy.typeIntoTerminal("{downArrow}")
    })
  })

  it("can open a directory with `:edit .`", () => {
    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: ["add_command_to_count_open_buffers.lua"],
      filename: {
        openInVerticalSplits: ["initial-file.txt", "file2.txt"],
      },
    }).then((nvim) => {
      cy.contains(nvim.dir.contents["initial-file.txt"].name)

      // open the current directory using a command
      cy.typeIntoTerminal(":edit .{enter}")

      // yazi should now be visible, showing the names of adjacent files
      cy.contains("-- TERMINAL --")
      cy.contains(nvim.dir.contents["file2.txt"].name)

      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")

      nvim.runExCommand({ command: "CountBuffers" }).then((result) => {
        expect(result.value).to.equal("Number of open buffers: 2")
      })
    })
  })

  it("can open a directory when pressing enter on a directory in yazi", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      cy.contains(nvim.dir.contents["initial-file.txt"].name)

      cy.typeIntoTerminal("{upArrow}")
      cy.contains("-- TERMINAL --")
      cy.contains(nvim.dir.contents["file2.txt"].name)

      // select a directory
      cy.typeIntoTerminal("/routes{enter}")
      // the contents of the directory should now be visible
      cy.contains("posts.$postId")

      // open the directory
      cy.typeIntoTerminal("{enter}")

      // yazi should now be visible in the new directory
      cy.contains("-- TERMINAL --")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // yazi should now be in insert mode. This means pressing q should exit.
      cy.typeIntoTerminal("q")

      cy.contains("-- TERMINAL --").should("not.exist")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ).should("not.exist")
    })
  })
})
