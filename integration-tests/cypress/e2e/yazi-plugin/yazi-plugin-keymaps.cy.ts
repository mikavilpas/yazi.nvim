import type { MyTestDirectoryFile } from "../../../MyTestDirectory.ts"
import type {
  MyStartNeovimServerArguments,
  NeovimContext,
} from "../../support/tui-sandbox.ts"
import { hoverFileAndVerifyItsHovered } from "../utils/hover-utils.ts"
import {
  assertYaziIsReady,
  isFileNotSelectedInYazi,
  isFileSelectedInYazi,
} from "../utils/yazi-utils.ts"
import {
  assertKeymapNotOwnedByYaziNvim,
  assertNvimYaziPluginIndicatorIsVisible,
  describeOnNightlyYazi,
} from "./yazi-plugin-utils.ts"

const openNeovimWithNvimYaziPlugin = (
  args?: MyStartNeovimServerArguments,
): Cypress.Chainable<NeovimContext> =>
  cy.startNeovim({
    ...args,
    startupScriptModifications: [
      "add_yazi_context_assertions.lua",
      "yazi_config/enable_yazi_plugin_keymaps.lua",
      ...(args?.startupScriptModifications ?? []),
    ],
  })

describeOnNightlyYazi("yazi-owned keymaps (nvim.yazi plugin, DDS)", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("<c-v> can open a file in a vertical split", () => {
    openNeovimWithNvimYaziPlugin().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      assertNvimYaziPluginIndicatorIsVisible()

      assertKeymapNotOwnedByYaziNvim(nvim, "<c-v>")

      // <c-v> is now owned by yazi (via the nvim.yazi plugin). Pressing it
      // publishes a DDS event that yazi.nvim reacts to by opening the hovered
      // file in a vertical split - exactly like the terminal-map version.
      cy.typeIntoTerminal("{control+v}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // both files must be visible (side by side in splits)
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  it("<c-v> can open multiple files in vertical splits", () => {
    openNeovimWithNvimYaziPlugin().then((nvim) => {
      // this should test that the DDS events include details of multiple
      // files, not just one
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      assertNvimYaziPluginIndicatorIsVisible()
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      cy.typeIntoTerminal("v")
      isFileNotSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)
      cy.typeIntoTerminal("j")
      isFileSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)

      assertKeymapNotOwnedByYaziNvim(nvim, "<c-v>")

      // <c-v> is now owned by yazi (via the nvim.yazi plugin). Pressing it
      // publishes a DDS event that yazi.nvim reacts to by opening the hovered
      // file in a vertical split - exactly like the terminal-map version.
      cy.typeIntoTerminal("{control+v}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // both files must be visible (side by side in splits)
      cy.contains(nvim.dir.contents["file3.txt"].name)
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  it("<c-x> can open a file in a horizontal split", () => {
    openNeovimWithNvimYaziPlugin().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      assertNvimYaziPluginIndicatorIsVisible()

      assertKeymapNotOwnedByYaziNvim(nvim, "<c-x>")

      cy.typeIntoTerminal("{control+x}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // both files must be visible
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  it("keymaps are documented in yazi's help view", () => {
    openNeovimWithNvimYaziPlugin().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      assertNvimYaziPluginIndicatorIsVisible()

      cy.typeIntoTerminal("~")
      cy.contains("yazi.nvim: open file in vertical split")
    })
  })

  it("can open a file in a new tab", () => {
    openNeovimWithNvimYaziPlugin().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      assertNvimYaziPluginIndicatorIsVisible()
      assertKeymapNotOwnedByYaziNvim(nvim, "<c-t>")

      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      cy.typeIntoTerminal("{control+t}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      cy.contains(
        // match some text from inside the file
        "Hello",
      )
      nvim.runExCommand({ command: "tabnext" })

      cy.contains("If you see this text, Neovim is ready!")

      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })
})
