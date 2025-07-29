import { flavors } from "@catppuccin/palette"
import { hoverFileAndVerifyItsHovered, rgbify } from "./utils/hover-utils"
import { assertYaziIsReady } from "./utils/yazi-utils"

describe("toggling yazi to pseudo-continue the previous session", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can restore yazi hovering on the previously hovered file", () => {
    cy.startNeovim({
      filename: "initial-file.txt",
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // This should send a hover event, which should be saved as the "last
      // hovered file"
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")

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
    cy.startNeovim({
      filename: "dir with spaces/file1.txt",
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("this is the first file")

      // toggle yazi and set up a session that hovers a directory
      cy.typeIntoTerminal("{upArrow}")
      cy.log("yazi should be visible, showing other files")
      assertYaziIsReady(nvim)
      hoverFileAndVerifyItsHovered(nvim, "dir with spaces/file1.txt")

      // yazi should be visible, showing other files
      cy.contains(nvim.dir.contents["file2.txt"].name)

      // focus "dir with spaces" in the parent directory
      hoverFileAndVerifyItsHovered(nvim, "dir with spaces")

      // close yazi
      assertYaziIsReady(nvim)
      cy.typeIntoTerminal("q")

      // toggle yazi again. It should hover the same directory.
      cy.typeIntoTerminal("{control+upArrow}")
      cy.contains("dir with spaces").should(
        "have.css",
        "background-color",
        rgbify(flavors.macchiato.colors.blue.rgb),
      )
    })
  })

  it("removes old, internal yazi states on `collectgarbage()`", () => {
    // The states of previous yazis are kept around internally until lua
    // decides to collectgarbage(). This happens periodically and usually is
    // not an issue as long as they are eventually collected.
    //
    // Here we test that collectgarbage() is able to remove the old states by
    // forcing it to happen. Normally it happens automatically and
    // periodically.
    cy.startNeovim({
      filename: "dir with spaces/file1.txt",
      startupScriptModifications: ["add_yazi_context_assertions.lua"],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("this is the first file")

      {
        // toggle yazi a couple of times to populate the internal states
        cy.typeIntoTerminal("{upArrow}")
        cy.contains("-- TERMINAL --")
        assertYaziIsReady(nvim)
        cy.typeIntoTerminal("q")
        cy.contains("-- TERMINAL --").should("not.exist")

        cy.typeIntoTerminal("{upArrow}")
        cy.contains("-- TERMINAL --")
        assertYaziIsReady(nvim)
        cy.typeIntoTerminal("q")
        cy.contains("-- TERMINAL --").should("not.exist")

        cy.typeIntoTerminal("{upArrow}")
        cy.contains("-- TERMINAL --")
        assertYaziIsReady(nvim)
        cy.typeIntoTerminal("q")
        cy.contains("-- TERMINAL --").should("not.exist")
      }

      nvim
        .runLuaCode({
          luaCode: `return vim.tbl_count(require("yazi.process.ya_process").known_yazis)`,
        })
        .then((result) => expect(result.value).eql(3))

      // force garbage collection to happen right away
      nvim.runLuaCode({ luaCode: `collectgarbage()` })

      nvim
        .runLuaCode({
          luaCode: `return vim.tbl_count(require("yazi.process.ya_process").known_yazis)`,
        })
        .then((result) => {
          // one yazi seems to be always kept around, but it's not a problem
          expect(result.value).to.be.lessThan(2)
        })
    })
  })
})
