import type { MyTestDirectoryFile } from "MyTestDirectory"
import tinycolor2 from "tinycolor2"
import {
  darkBackgroundColors,
  hoverFileAndVerifyItsHovered,
  isHoveredInNeovim,
  isHoveredInNeovimWithSameDirectory,
  isNotHoveredInNeovim,
  lightBackgroundColors,
} from "./utils/hover-utils"
import { assertYaziIsReady } from "./utils/yazi-utils"

describe("highlighting the buffer with 'hover' events", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  // NOTE: when opening the file, the cursor is placed at the beginning of
  // the file. This causes the web terminal to render multiple elements for the
  // same text, and this can cause issues when matching colors, as in the DOM
  // there really are multiple colors present. Work around this by matching a
  // substring of the text instead of the whole text.

  it("can highlight the buffer when hovered", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "yazi_config/add_hovered_buffer_background.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverFileAndVerifyItsHovered(nvim, "initial-file.txt")

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
        "add_yazi_context_assertions.lua",
        "yazi_config/add_hovered_buffer_background.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // yazi is shown and adjacent files should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)

      hoverFileAndVerifyItsHovered(nvim, "initial-file.txt")

      // the current file is highlighted by default when
      // opening yazi. This should have sent the 'hover' event and caused the
      // Neovim window to be shown with a different background color
      isHoveredInNeovim("If you see this text, Neovim is ready!")

      // hover another file - the highlight should be removed
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      // make sure yazi is focused on the correct file. Sometimes if the keys
      // are sent too quickly, they are included in an incorrect order.
      cy.contains("Hello")

      isNotHoveredInNeovim("If you see this text, Neovim is ready!")
    })
  })

  it("can move the highlight to another buffer when hovering over it", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "yazi_config/add_hovered_buffer_background.lua",
        "add_command_to_reveal_a_file.lua",
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
      assertYaziIsReady(nvim)
      cy.contains("-- TERMINAL --")

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      isHoveredInNeovim(file2Text)

      // select the other file - the highlight should move to it
      hoverFileAndVerifyItsHovered(nvim, "initial-file.txt")

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
      cy.startNeovim({
        startupScriptModifications: [
          "add_command_to_reveal_a_file.lua",
          "add_yazi_context_assertions.lua",
        ],
      }).then((nvim) => {
        // wait until text on the start screen is visible
        isNotHoveredInNeovim("f you see this text, Neovim is ready!")

        // start yazi
        cy.typeIntoTerminal("{upArrow}")
        assertYaziIsReady(nvim)

        // yazi should be visible now
        cy.contains(nvim.dir.contents["file2.txt"].name)
        hoverFileAndVerifyItsHovered(nvim, "file2.txt")

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        hoverFileAndVerifyItsHovered(nvim, "initial-file.txt")

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
        startupScriptModifications: [
          "add_yazi_context_assertions.lua",
          "use_light_neovim_colorscheme.lua",
          "add_command_to_reveal_a_file.lua",
        ],
      }).then((nvim) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")
          .children()
          .should("have.css", "background-color", lightBackgroundColors.normal)

        // start yazi
        cy.typeIntoTerminal("{upArrow}")
        assertYaziIsReady(nvim)

        // yazi should be visible now
        cy.contains(nvim.dir.contents["file2.txt"].name)
        hoverFileAndVerifyItsHovered(nvim, "file2.txt")

        // yazi is shown and adjacent files should be visible now
        //
        // highlight the initial file
        hoverFileAndVerifyItsHovered(nvim, "initial-file.txt")
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
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "notify_hover_events.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      // yazi should be visible now
      cy.contains(nvim.dir.contents["file2.txt"].name)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")

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
        "add_yazi_context_assertions.lua",
        "yazi_config/highlight_buffers_in_same_directory.lua",
        "add_command_to_reveal_a_file.lua",
      ],
      filename: {
        openInVerticalSplits: ["initial-file.txt", "file2.txt"],
      },
    }).then((nvim) => {
      // wait until text on the start screen is visible
      isNotHoveredInNeovim("f you see this text, Neovim is ready!")
      isNotHoveredInNeovim("Hello")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      // yazi should be visible now
      cy.contains("subdirectory" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file3.txt")

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

  const view = {
    leftFile: { text: "ello from file_1.txt" },
    centerFile: { text: "This is file_2.txt" },
    rightFile: { text: "You are looking at file_3.txt" },
  } as const

  it("can highlight after `:Yazi cwd`", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "yazi_config/highlight_buffers_in_same_directory.lua",
        "add_command_to_reveal_a_file.lua",
      ],
      filename: {
        openInVerticalSplits: [
          "highlights/file_1.txt",
          "highlights/file_2.txt",
          "highlights/file_3.txt",
        ],
      },
    }).then((nvim) => {
      // wait until text on the start screen is visible
      // sanity check to make sure the files are open
      cy.contains(view.leftFile.text)
      cy.contains(view.centerFile.text)
      cy.contains(view.rightFile.text)

      nvim.runExCommand({ command: `:Yazi cwd` })
      assertYaziIsReady(nvim)

      // before doing anything, both files should be unhovered (have the
      // default background color)
      isNotHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovimWithSameDirectory(view.centerFile.text)
      isHoveredInNeovimWithSameDirectory(view.rightFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovimWithSameDirectory(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isHoveredInNeovimWithSameDirectory(view.rightFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovimWithSameDirectory(view.leftFile.text)
      isHoveredInNeovimWithSameDirectory(view.centerFile.text)
      isHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovimWithSameDirectory(view.centerFile.text)
      isHoveredInNeovimWithSameDirectory(view.rightFile.text)
    })
  })
})
