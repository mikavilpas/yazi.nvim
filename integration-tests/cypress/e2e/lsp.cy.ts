import assert from "assert"
import type { NeovimContext } from "cypress/support/tui-sandbox"
import { join } from "path"
import { waitForRenameToHaveBeenConfirmed } from "./utils/lsp-utils"
import { assertYaziIsReady, isFileSelectedInYazi } from "./utils/yazi-utils"

describe("rename events with LSP support", () => {
  let currentNeovim: NeovimContext | undefined

  afterEach(function () {
    if (this.currentTest?.state === "failed") {
      assert(currentNeovim)
      const logFilePath = join(
        currentNeovim.dir.rootPathAbsolute,
        ".local/state/nvim_integrations/lsp.log",
      )
      cy.task("showLspLogFile", { logFilePath: logFilePath })
    }
  })

  it("can rename a file with LSP support", () => {
    // When an LSP server is running, and a file is renamed in yazi, yazi.nvim
    // can use the LSP server to rename the file and all its references in the
    // project.
    cy.visit("/")
    cy.startNeovim({
      filename: "lua-project/lua/config.lua",
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "accept_lsp_rename_confirmations_immediately.lua",
      ],
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      currentNeovim = nvim
      // wait until text on the start screen is visible
      cy.contains(`-- the default configuration`)

      // It takes a bit of time for the LSP server to start.
      //
      // This is a pretty hacky way to know when the LSP server is ready. It
      // shows an "unused" warning when it has started :)
      nvim.waitForLuaCode({
        luaAssertion: `assert(#vim.diagnostic.get(0) == -1)`,
        timeoutMs: 1_000,
      })

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      isFileSelectedInYazi("config.lua")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")
      cy.typeIntoTerminal("q")

      waitForRenameToHaveBeenConfirmed(nvim)

      // go back to the init.lua file and verify the require path was updated
      nvim.runExCommand({ command: `edit %:h/init.lua` })
      cy.contains(`local config = require('config2')`)
    })
  })
})
