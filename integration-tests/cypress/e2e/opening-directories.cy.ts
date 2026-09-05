describe("opening directories", () => {
  it("can open a directory when starting with `neovim .`", () => {
    cy.visit("/")
    cy.startNeovim({
      // `neovim .` specifies to open the current directory when neovim is
      // starting
      filename: ".",
    }).then(nvim => {
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
    }).then(nvim => {
      cy.contains(nvim.dir.contents["initial-file.txt"].name)

      // open the current directory using a command
      cy.typeIntoTerminal(":edit .{enter}")

      // yazi should now be visible, showing the names of adjacent files
      cy.contains("-- TERMINAL --")
      cy.contains(nvim.dir.contents["file2.txt"].name)

      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")

      nvim.runExCommand({ command: "CountBuffers" }).then(result => {
        expect(result.value).to.equal("Number of open buffers: 2")
      })
    })
  })

  describe("when loading yazi without a package manager", () => {
    it("can open a directory when starting with `neovim .`", () => {
      cy.visit("/")
      cy.startNeovim({
        // `neovim .` specifies to open the current directory when neovim is
        // starting
        filename: ".",
        NVIM_APPNAME: "nvim_no_package_manager",
        startupScriptModifications: ["nvim_no_package_manager/load_yazi_instead_of_netrw.lua", "add_winborder.lua"],
      }).then(nvim => {
        // yazi should now be visible, showing the names of adjacent files
        cy.contains("-- TERMINAL --")
        cy.contains(nvim.dir.contents["file2.txt"].name)
      })
    })
  })
})
