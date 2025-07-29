import type { MyTestDirectoryFile } from "MyTestDirectory"
import path from "path"
import z from "zod"
import { hoverFileAndVerifyItsHovered } from "./utils/hover-utils"
import { assertYaziIsReady } from "./utils/yazi-utils"

describe("reading events", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use key-event.yazi to change the cwd on yazi quit", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
        "yazi_config/prepare_key_event_plugin.lua",
        "yazi_config/load_yazi_with_plugins_config.lua",
      ],
      NVIM_APPNAME: "nvim_integrations",
      additionalEnvironmentVariables: {
        // https://yazi-rs.github.io/docs/plugins/overview/#logging
        // ~/.local/state/yazi/yazi.log
        YAZI_LOG: "debug",
      },
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      // symlink the plugin so that it's available for yazi to use. The build
      // steps are defined in the `init.lua` file where yazi.nvim is
      // configured.
      nvim.runExCommand({ command: `Lazy! build yazi.nvim` })

      // verify the pwd before doing anything
      nvim.runExCommand({ command: "pwd" }).then((result) => {
        const pwd = z.string().parse(result.value)
        expect(pwd + "/").to.eql(nvim.dir.testEnvironmentPath)
      })

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      hoverFileAndVerifyItsHovered(nvim, "subdirectory/subdirectory-file.txt")

      cy.contains("-- TERMINAL --")
      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")

      // the pwd should have changed
      nvim.runExCommand({ command: "pwd" }).then((result) => {
        const pwd = z.string().parse(result.value)
        expect(pwd).to.eql(
          path.resolve(
            nvim.dir.rootPathAbsolute,
            "subdirectory" satisfies MyTestDirectoryFile,
          ),
        )
      })
    })
  })
})
