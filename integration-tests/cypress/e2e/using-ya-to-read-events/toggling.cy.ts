describe("toggling yazi to pseudo-continue the previous session", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  function hoverAnotherFileToEnsureHoverEventIsReceivedInCI(file: string) {
    // select another file (hacky)
    cy.typeIntoTerminal("gg")

    // select the desired file so that a new hover event is sent
    cy.typeIntoTerminal(`/${file}{enter}`)
  }

  it("can restore yazi hovering on the previously hovered file", () => {
    cy.startNeovim({ filename: "initial-file.txt" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // select another file. This should send a hover event, which should be
      // saved as the "last hovered file"

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        nvim.dir.contents["file2.txt"].name,
      )

      // close yazi
      cy.typeIntoTerminal("q")

      // the hovered file should not be visible any longer
      cy.contains(nvim.dir.contents["file2.txt"].name).should("not.exist")

      // start yazi again by toggling it
      cy.typeIntoTerminal("{control+upArrow}")

      // the previously hovered file should be visible again
      cy.contains(nvim.dir.contents["file2.txt"].name)
    })
  })

  it("can toggle yazi even if no previous session exists", () => {
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // toggle yazi
      cy.typeIntoTerminal("{control+upArrow}")

      // yazi should be visible, showing other files
      cy.contains(nvim.dir.contents["file2.txt"].name)
    })
  })
})
