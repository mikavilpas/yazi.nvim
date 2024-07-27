import assert = require("assert")
import { startNeovimWithYa } from "./using-ya-to-read-events/startNeovimWithYa"

describe("the help menu", () => {
  it("can show help with a keymap", () => {
    cy.visit("http://localhost:5173")
    startNeovimWithYa({
      startupScriptModifications: ["modify_yazi_config_and_set_help_key.lua"],
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // open yazi and wait for it to load
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)

      cy.typeIntoTerminal("{del}")
      cy.contains("yazi.nvim help")

      // the config for this test overrides the help key to be <del>. Make sure
      // overrides are shown
      cy.contains("<del> - show this help")

      // the version of yazi.nvim should be shown
      cy.readFile("../.release-please-manifest.json").then(
        (yaziNvimManifest: unknown) => {
          assert(typeof yaziNvimManifest === "object")
          assert(yaziNvimManifest)
          assert("." in yaziNvimManifest)
          assert(typeof yaziNvimManifest["."] === "string")
          cy.contains(`version ${yaziNvimManifest["."]}`)
        },
      )

      // The help buffer must not be modifiable. Don't assert the text as it
      // may be translated to the developer's own language.
      cy.typeIntoTerminal("i")
      cy.contains("E21") // Cannot make changes, 'modifiable' is off

      // close the help buffer. It should enable insert mode in the yazi buffer.
      cy.typeIntoTerminal("q")
      cy.contains("yazi.nvim help").should("not.exist")

      // it should now be possible to close yazi, since it's in insert mode
      // and ready to accept commands
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.typeIntoTerminal("q")
      cy.contains(dir.contents["test-setup.lua"].name).should("not.exist")
    })
  })
})
