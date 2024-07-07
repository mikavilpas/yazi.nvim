import { flavors } from "@catppuccin/palette"
import { startNeovimWithYa } from "./startNeovimWithYa"

const surface0 = flavors.macchiato.colors.surface1.rgb
const base = flavors.macchiato.colors.base.rgb

function rgbify(color: typeof surface0) {
  return `rgb(${color.r.toString()}, ${color.g.toString()}, ${color.b.toString()})`
}

describe("highlighting the buffer with 'hover' events", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  const backgroundColors = {
    normal: rgbify(base),
    hovered: rgbify(surface0),
  } as const

  // NOTE: when opening the file, the cursor is placed at the beginning of
  // the file. This causes the web terminal to render multiple elements for the
  // same text, and this can cause issues when matching colors, as in the DOM
  // there are multiple colors. Work around this by matching a substring of the
  // text instead of the whole text.

  /** HACK in CI, there can be timing issues where the first hover event is
   * lost. Right now we work around this by selecting another file first, then
   * hovering the desired file.
   */
  function hoverAnotherFileToEnsureHoverEventIsReceivedInCI(file: string) {
    // select another file (hacky)
    cy.typeIntoTerminal("gg")

    // select the desired file so that a new hover event is sent
    cy.typeIntoTerminal(`/${file}{enter}`)
  }

  it("can highlight the buffer when hovered", () => {
    startNeovimWithYa({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
        .children()
        .should("have.css", "background-color", backgroundColors.normal)

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["initial-file.txt"].name,
      )

      // yazi is shown and adjacent files should be visible now
      //
      // the current file (initial-file.txt) is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      cy.contains("If you see this text, Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.hovered,
      )

      // close yazi - the highlight should be removed and we should see the
      // same color as before
      cy.typeIntoTerminal("q")
      cy.contains("Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.normal,
      )
    })
  })

  it("can remove the highlight when the cursor is moved away", () => {
    startNeovimWithYa({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.normal,
      )

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi is shown and adjacent files should be visible now
      cy.contains(dir.contents["test.lua"].name)

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["initial-file.txt"].name,
      )

      // the current file (initial-file.txt) is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      cy.contains("Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.hovered,
      )

      // hover another file - the highlight should be removed
      cy.typeIntoTerminal(`/^${dir.contents["test.lua"].name}{enter}`)

      cy.contains("Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.normal,
      )
    })
  })

  it("can move the highlight to another buffer when hovering over it", () => {
    startNeovimWithYa({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
        .children()
        .should("have.css", "background-color", backgroundColors.normal)

      const testFile = dir.contents["test.lua"].name
      // open an adjacent file and wait for it to be displayed
      cy.typeIntoTerminal(`:vsplit ${dir.rootPath}/${testFile}{enter}`, {
        delay: 1,
      })
      cy.contains("how to initialize the test environment")

      // start yazi - the initial file should be highlighted
      cy.typeIntoTerminal("{upArrow}")

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(testFile)
      cy.contains("how to initialize the test environment").should(
        "have.css",
        "background-color",
        backgroundColors.hovered,
      )

      // select the other file - the highlight should move to it
      cy.typeIntoTerminal(`/^${dir.contents["initial-file.txt"].name}{enter}`, {
        delay: 1,
      })
      cy.contains("how to initialize the test environment").should(
        "have.css",
        "background-color",
        backgroundColors.normal,
      )
      cy.contains("If you see this text, Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.hovered,
      )
    })
  })

  it("doesn't crash if the user doesn't want to highlight", () => {
    // "not wanting to highlight" means that the user hasn't enabled the
    // highlight in their YaziConfig. It is acceptable to opt out of using this
    // feature, and it shouldn't cause a crash.

    // NOTE don't set the startupScriptModifications. This causes the highlight
    // to not be enabled in the YaziConfig.
    startNeovimWithYa({ startupScriptModifications: [] }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
        .children()
        .should("have.css", "background-color", backgroundColors.normal)

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["test.lua"].name,
      )

      // yazi is shown and adjacent files should be visible now
      //
      // highlight the initial file
      cy.typeIntoTerminal(`/${dir.contents["initial-file.txt"].name}{enter}`)
      cy.contains("Error").should("not.exist")

      // no highlight should be visible
      cy.contains("If you see this text, Neovim is ready!").should(
        "have.css",
        "background-color",
        backgroundColors.normal,
      )
    })
  })
})
