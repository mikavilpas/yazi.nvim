import type { MyTestDirectoryFile } from "MyTestDirectory"
import tinycolor2 from "tinycolor2"
import {
  darkBackgroundColors,
  isHoveredInNeovim,
  isNotHoveredInNeovim,
  lightBackgroundColors,
} from "./utils/hover-utils"

describe("highlighting the buffer with 'hover' events", () => {
  beforeEach(() => {
    cy.visit("/")
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
    cy.typeIntoTerminal("f")
    cy.contains("Filter:")
    cy.typeIntoTerminal("txt{enter}")

    // select another file (hacky) by going to the parent directory and then
    // back
    cy.typeIntoTerminal("hl")

    // select the desired file so that a new hover event is sent
    cy.typeIntoTerminal(`/${file}{enter}`, { delay: 10 })

    // yazi should display a notification/status message about the filter and
    // search being active
    cy.contains("filter: txt, find: ")

    // exit filter mode
    cy.typeIntoTerminal("{esc}")
    cy.contains("filter: txt")
  }

  it("can highlight the buffer when hovered", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        nvim.dir.contents["initial-file.txt"].name,
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
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi is shown and adjacent files should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)

      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        nvim.dir.contents["initial-file.txt"].name,
      )

      // the current file is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      isHoveredInNeovim("If you see this text, Neovim is ready!")

      // hover another file - the highlight should be removed
      cy.typeIntoTerminal(`/^${nvim.dir.contents["file2.txt"].name}{enter}`, {
        delay: 10,
      })
      // make sure yazi is focused on the correct file. Sometimes if the keys
      // are sent too quickly, they are included in an incorrect order.
      cy.contains("find: ^file2.txt)")

      isNotHoveredInNeovim("If you see this text, Neovim is ready!")
    })
  })

  it("can move the highlight to another buffer when hovering over it", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      const testFile = nvim.dir.contents["file2.txt"].name
      // open an adjacent file and wait for it to be displayed
      cy.typeIntoTerminal(
        `:vsplit ${nvim.dir.testEnvironmentPathRelative}/${testFile}{enter}`,
        {
          delay: 0,
        },
      )

      const file2Text = "Hello"
      cy.contains(file2Text)

      // start yazi - the initial file should be highlighted
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("-- TERMINAL --")

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(testFile)
      isHoveredInNeovim(file2Text)

      // select the other file - the highlight should move to it
      cy.typeIntoTerminal(
        `/^${nvim.dir.contents["initial-file.txt"].name}{enter}`,
        {
          delay: 10,
        },
      )
      // make sure yazi is focused on the correct file. Sometimes if the keys
      // are sent too quickly, they are included in an incorrect order, such
      // as "initila-file"
      cy.contains("find: ^initial-file.txt)")

      isNotHoveredInNeovim(file2Text)
      isHoveredInNeovim("If you see this text, Neovim is ready!")
    })
  })

  describe("default colors", () => {
    // If the user hasn't specified a custom highlight color, yazi.nvim will
    // create a default color for them. The default colors are created based on
    // the current colorscheme - by darkening or lightening an existing color.
    //
    it("for a dark colorscheme, hovers appear lighter in color", () => {
      cy.startNeovim({ startupScriptModifications: [] }).then((nvim) => {
        // wait until text on the start screen is visible
        isNotHoveredInNeovim("f you see this text, Neovim is ready!")

        // start yazi
        cy.typeIntoTerminal("{upArrow}")

        // yazi should be visible now
        cy.contains(nvim.dir.contents["file2.txt"].name)
        hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
          nvim.dir.contents["file2.txt"].name,
        )

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        cy.typeIntoTerminal(
          `/${nvim.dir.contents["initial-file.txt"].name}{enter}`,
        )
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

    it("for a light colorscheme, hovers appear darker", () => {
      cy.startNeovim({
        startupScriptModifications: ["use_light_neovim_colorscheme.lua"],
      }).then((nvim) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")
          .children()
          .should("have.css", "background-color", lightBackgroundColors.normal)

        // start yazi
        cy.typeIntoTerminal("{upArrow}")

        // yazi should be visible now
        cy.contains(nvim.dir.contents["file2.txt"].name)
        hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
          nvim.dir.contents["file2.txt"].name,
        )

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        cy.typeIntoTerminal(
          `/${nvim.dir.contents["initial-file.txt"].name}{enter}`,
        )
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
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        nvim.dir.contents["file2.txt"].name,
      )

      cy.typeIntoTerminal("q")
      nvim
        .runLuaCode({ luaCode: `return _G.yazi_test_events` })
        .should((result) => {
          const events = result.value as unknown[]
          expect(events.length).to.be.greaterThan(1)

          const firstEvent = JSON.stringify(events[0])
          expect(firstEvent).to.contain("Just received a YaziDDSHover event!")
          expect(firstEvent).to.contain(`"type":"hover"`)
        })
    })
  })

  it("can highlight buffers that are open in the current yazi directory", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_and_highlight_buffers_in_same_directory.lua",
      ],
      filename: {
        openInVerticalSplits: ["initial-file.txt", "file2.txt"],
      },
    }).then((_nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")
      isNotHoveredInNeovim("Hello")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi should be visible now
      cy.contains("subdirectory" satisfies MyTestDirectoryFile)
      hoverAnotherFileToEnsureHoverEventIsReceivedInCI(
        "file3.txt" satisfies MyTestDirectoryFile,
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
