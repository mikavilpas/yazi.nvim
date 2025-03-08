import { flavors } from "@catppuccin/palette"
import { rgbify } from "./utils/hover-utils"

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

  it("can toggle yazi, hovering a directory", () => {
    // by default in yazi, starting and hovering a directory is not supported.
    // Yazi displays the contents of the directory instead of hovering the
    // directory. We work around this by sending a "reveal" event to yazi to
    // hover the directory instead.
    cy.startNeovim({ filename: "dir with spaces/file1.txt" }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("this is the first file")

      // toggle yazi and set up a session that hovers a directory
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible, showing other files
      cy.contains(nvim.dir.contents["file2.txt"].name)

      // move to the upper directory level. This will focus "dir with spaces"
      cy.typeIntoTerminal("h")
      cy.contains("dir with spaces").should(
        "have.css",
        "background-color",
        rgbify(flavors.macchiato.colors.blue.rgb),
      )

      // close yazi
      cy.contains("NOR")
      cy.typeIntoTerminal("q")
      cy.contains("NOR").should("not.exist")

      // toggle yazi again. It should hover the same directory.
      cy.typeIntoTerminal("{control+upArrow}")
      cy.contains("dir with spaces").should(
        "have.css",
        "background-color",
        rgbify(flavors.macchiato.colors.blue.rgb),
      )
    })
  })
})
