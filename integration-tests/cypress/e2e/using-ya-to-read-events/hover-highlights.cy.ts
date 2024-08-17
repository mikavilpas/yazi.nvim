import tinycolor2 from "tinycolor2"
import {
  darkBackgroundColors,
  isHoveredInNeovim,
  isNotHoveredInNeovim,
  lightBackgroundColors,
} from "./utils/hover-utils"

describe("highlighting the buffer with 'hover' events", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  // NOTE: when opening the file, the cursor is placed at the beginning of
  // the file. This causes the web terminal to render multiple elements for the
  // same text, and this can cause issues when matching colors, as in the DOM
  // there really are multiple colors present. Work around this by matching a
  // substring of the text instead of the whole text.

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
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(dir.contents["test-setup.lua"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["initial-file.txt"].name,
      )

      // yazi is shown and adjacent files should be visible now
      //
      // the current file is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      isHoveredInNeovim("If you see this text, Neovim is ready!")

      // close yazi - the highlight should be removed and we should see the
      // same color as before
      cy.typeIntoTerminal("q")
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")
    })
  })

  it("can remove the highlight when the cursor is moved away", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi is shown and adjacent files should be visible now
      cy.contains(dir.contents["test-setup.lua"].name)

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["initial-file.txt"].name,
      )

      // the current file is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      isHoveredInNeovim("If you see this text, Neovim is ready!")

      // hover another file - the highlight should be removed
      cy.typeIntoTerminal(`/^${dir.contents["test-setup.lua"].name}{enter}`)

      isNotHoveredInNeovim("If you see this text, Neovim is ready!")
    })
  })

  it("can move the highlight to another buffer when hovering over it", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((dir) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      const testFile = dir.contents["test-setup.lua"].name
      // open an adjacent file and wait for it to be displayed
      cy.typeIntoTerminal(
        `:vsplit ${dir.rootPathAbsolute}/${testFile}{enter}`,
        {
          delay: 1,
        },
      )
      cy.contains("how to initialize the test environment")

      // start yazi - the initial file should be highlighted
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(dir.contents["test-setup.lua"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(testFile)
      isHoveredInNeovim("how to initialize the test environment")

      // select the other file - the highlight should move to it
      cy.typeIntoTerminal(`/^${dir.contents["initial-file.txt"].name}{enter}`, {
        delay: 1,
      })
      isNotHoveredInNeovim("how to initialize the test environment")
      isHoveredInNeovim("If you see this text, Neovim is ready!")
    })
  })

  describe("default colors", () => {
    // If the user hasn't specified a custom highlight color, yazi.nvim will
    // create a default color for them. The default colors are created based on
    // the current colorscheme - by darkening or lightening an existing color.
    //
    it("for a dark colorscheme, hovers appear lighter in color", () => {
      cy.startNeovim({ startupScriptModifications: [] }).then((dir) => {
        // wait until text on the start screen is visible
        isNotHoveredInNeovim("f you see this text, Neovim is ready!")

        // start yazi
        cy.typeIntoTerminal("{upArrow}")

        // yazi should be visible now
        cy.contains(dir.contents["test-setup.lua"].name)
        hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
          dir.contents["test-setup.lua"].name,
        )

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        cy.typeIntoTerminal(`/${dir.contents["initial-file.txt"].name}{enter}`)
        cy.contains("Error").should("not.exist")

        // the background color should be different from the default color
        cy.contains("If you see this text, Neovim is ready!")
          .should("have.css", "background-color")
          .should((color) => {
            expect(tinycolor2(color).getLuminance()).to.be.greaterThan(
              tinycolor2(darkBackgroundColors.normal).getLuminance(),
            )
          })
      })
    })

    it("for a light colorscheme", () => {
      cy.startNeovim({
        startupScriptModifications: ["use_light_neovim_colorscheme.lua"],
      }).then((dir) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")
          .children()
          .should("have.css", "background-color", lightBackgroundColors.normal)

        // start yazi
        cy.typeIntoTerminal("{upArrow}")

        // yazi should be visible now
        cy.contains(dir.contents["test-setup.lua"].name)
        hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
          dir.contents["test-setup.lua"].name,
        )

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        cy.typeIntoTerminal(`/${dir.contents["initial-file.txt"].name}{enter}`)
        cy.contains("Error").should("not.exist")

        // the background color should be different from the default color
        cy.contains("If you see this text, Neovim is ready!")
          .should("have.css", "background-color")
          .should((color) => {
            expect(tinycolor2(color).getLuminance()).to.be.lessThan(
              tinycolor2(lightBackgroundColors.normal).getLuminance(),
            )
          })
      })
    })
  })

  it("supports external integrations to hover events", () => {
    cy.startNeovim({
      startupScriptModifications: ["notify_hover_events.lua"],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(dir.contents["test-setup.lua"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["test-setup.lua"].name,
      )

      cy.typeIntoTerminal("q")
      cy.typeIntoTerminal(":messages{enter}")

      // Hovering a new file should have triggered the integration
      //
      // the main message from the integration in the
      // startupScriptModifications script should be visible. Check the file
      // to see the full integration.
      cy.contains("Just received a YaziDDSHover event!")

      // some event data should be visible. See the lua type YaziHoverEvent for
      // the structure
      cy.contains(`type = "hover"`)
    })
  })

  it("can highlight buffers that are open in the current yazi directory", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_highlight_buffers_in_same_directory.lua",
      ],
      filename: {
        openInVerticalSplits: ["initial-file.txt", "file.txt"],
      },
    }).then((dir) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")
      isNotHoveredInNeovim("Hello")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(dir.contents["test-setup.lua"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        dir.contents["test-setup.lua"].name,
      )

      isHoveredInNeovim(
        "f you see this text, Neovim is ready!",
        darkBackgroundColors.hoveredInSameDirectory,
      )
      isHoveredInNeovim("Hello", darkBackgroundColors.hoveredInSameDirectory)

      // highlights are cleared when yazi is closed
      cy.typeIntoTerminal("q")
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")
      isNotHoveredInNeovim("Hello")
    })
  })
})
