describe("toggling yazi to pseudo-continue the previous session", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  function hoverAnotherFileToEnsureHoverEventIsReceivedInCI(file: string) {
    // select another file (hacky)
    cy.typeIntoTerminal("gg")

    // select the desired file so that a new hover event is sent
    cy.typeIntoTerminal(`/${file}{enter}`)
  }

  it("can restore yazi hovering on the previously hovered file", () => {
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // select another file. This should send a hover event, which should be
      // saved as the "last hovered file"

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["test-setup.lua"].name,
      )

      // close yazi
      cy.typeIntoTerminal("q")

      // the hovered file should not be visible any longer
      cy.contains(dir.contents["test-setup.lua"].name).should("not.exist")

      // start yazi again by toggling it
      cy.typeIntoTerminal("{control+upArrow}")

      // the previously hovered file should be visible again
      cy.contains(dir.contents["test-setup.lua"].name)
    })
  })

  it("can toggle yazi even if no previous session exists", () => {
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // toggle yazi
      cy.typeIntoTerminal("{control+upArrow}")

      // yazi should be visible, showing other files
      cy.contains(dir.contents["test-setup.lua"].name)
    })
  })
})
