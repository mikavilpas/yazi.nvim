import type { MyNeovimConfigModification } from "@tui-sandbox/library"
import type { OverrideProperties } from "type-fest"

import type { MyTestDirectoryFile } from "../../../MyTestDirectory.ts"
import type {
  MyStartNeovimServerArguments,
  NeovimContext,
} from "../../support/tui-sandbox.ts"
import {
  assertYaziIsHovering,
  hoverFileAndVerifyItsHovered,
} from "../utils/hover-utils.ts"
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

type NonDefaultStartupModification = Exclude<
  MyNeovimConfigModification<MyTestDirectoryFile>,
  | "add_yazi_context_assertions.lua"
  | "yazi_config/enable_yazi_plugin_keymaps.lua"
>
const openNeovimWithNvimYaziPlugin = (
  args?: OverrideProperties<
    MyStartNeovimServerArguments,
    { startupScriptModifications?: NonDefaultStartupModification[] }
  >,
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

  it("can cycle_open_buffers", () => {
    openNeovimWithNvimYaziPlugin({
      filename: "initial-file.txt",
      startupScriptModifications: [
        "yazi_config/highlight_buffers_in_same_directory.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi and wait for it to be visible
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      assertKeymapNotOwnedByYaziNvim(nvim, "<tab>")

      // focus another file
      hoverFileAndVerifyItsHovered(nvim, "highlights/file_2.txt")

      cy.typeIntoTerminal("I")
      assertYaziIsHovering(nvim, "initial-file.txt")
    })
  })

  describe("telescope integration (search)", () => {
    // https://github.com/nvim-telescope/telescope.nvim
    beforeEach(() => {
      cy.visit("/")
    })

    it("can use telescope.nvim to search in the current directory", () => {
      openNeovimWithNvimYaziPlugin({
        filename: "routes/posts.$postId/adjacent-file.txt",
        NVIM_APPNAME: "nvim_integrations",
      }).then((nvim) => {
        cy.contains("this file is adjacent-file.txt")
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(
          nvim.dir.contents.routes.contents["posts.$postId"].contents[
            "route.tsx"
          ].name,
        )

        assertYaziIsReady(nvim)
        assertKeymapNotOwnedByYaziNvim(nvim, "<c-s>")
        cy.typeIntoTerminal("{control+s}")

        cy.contains(new RegExp(`Grep in testdirs/.*?/routes/posts.\\$postId`))
      })
    })

    it("can use telescope.nvim to search, limited to the selected files only", () => {
      openNeovimWithNvimYaziPlugin({
        filename: "routes/posts.$postId/adjacent-file.txt",
        NVIM_APPNAME: "nvim_integrations",
      }).then((nvim) => {
        cy.contains("this file is adjacent-file.txt")
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(
          nvim.dir.contents.routes.contents["posts.$postId"].contents[
            "route.tsx"
          ].name,
        )

        assertYaziIsReady(nvim)
        // select the current file and the file below. There are three files in
        // this directory so two will be selected and one will be left
        // unselected
        cy.typeIntoTerminal("vj")
        assertKeymapNotOwnedByYaziNvim(nvim, "<c-s>")
        cy.typeIntoTerminal("{control+s}")

        // telescope should be open now
        cy.contains("Grep Preview")
        cy.contains("Grep in 2 paths")

        // search for some file content. This should match
        // ../../../test-environment/routes/posts.$postId/adjacent-file.txt
        cy.typeIntoTerminal("this")

        // verify this manually for now as I'm a bit scared this will be too
        // flaky
      })
    })
  })

  describe("grug-far integration (search and replace)", () => {
    beforeEach(() => {
      cy.visit("/")
    })

    it("can use grug-far.nvim to search and replace in the directory of the hovered file", () => {
      openNeovimWithNvimYaziPlugin({
        filename: "routes/posts.$postId/adjacent-file.txt",
        NVIM_APPNAME: "nvim_integrations",
      }).then((nvim) => {
        // wait until text on the start screen is visible
        cy.contains("this file is adjacent-file.txt")

        cy.typeIntoTerminal("{upArrow}")
        cy.contains(
          nvim.dir.contents.routes.contents["posts.$postId"].contents[
            "should-be-excluded-file.txt"
          ].name,
        )
        assertYaziIsReady(nvim)
        assertKeymapNotOwnedByYaziNvim(nvim, "<c-g>")
        // close yazi and start grug-far.nvim
        cy.typeIntoTerminal("{control+g}")
        cy.contains("Grug FAR")

        // the directory we were in should be prefilled in grug-far.nvim's view
        cy.contains("testdirs")
        cy.contains("routes/posts.$postId" satisfies MyTestDirectoryFile)

        // by default, the focus is on the search field in normal mode. Type
        // something in the search field so we can see if results can be found
        cy.typeIntoTerminal("ithis")

        // maybe we don't want to make too many assertions on code we don't own
        // though, so for now we trust that it works in CI, and can verify it
        // works locally
      })
    })

    it("can search and replace, limited to selected files only", () => {
      openNeovimWithNvimYaziPlugin({
        filename: "routes/posts.$postId/adjacent-file.txt",
        NVIM_APPNAME: "nvim_integrations",
      }).then((nvim) => {
        cy.contains("this file is adjacent-file.txt")
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(
          nvim.dir.contents.routes.contents["posts.$postId"].contents[
            "route.tsx"
          ].name,
        )

        assertYaziIsReady(nvim)
        assertKeymapNotOwnedByYaziNvim(nvim, "<c-g>")
        // select the current file and the file below. There are three files in
        // this directory so two will be selected and one will be left
        // unselected
        cy.typeIntoTerminal("vj")
        cy.typeIntoTerminal("{control+g}")

        cy.contains("Grug FAR")
        cy.typeIntoTerminal("ithis")
        cy.typeIntoTerminal("{esc}")

        // close the split on the right so we can get some more space
        nvim.runExCommand({ command: "only" })

        // the selected files should be visible in the view, used as the files to
        // whitelist into the search and replace operation
        cy.contains("routes/posts.$postId/adjacent-file.txt")
        cy.contains("routes/posts.$postId/route.tsx")

        // the files in the same directory that were not selected should not be
        // visible in the view
        cy.contains("routes/posts.$postId/should-be-excluded-file.txt").should(
          "not.exist",
        )
      })
    })
  })

  it("can send file names to the quickfix list", () => {
    openNeovimWithNvimYaziPlugin({
      filename: "file2.txt",
      startupScriptModifications: ["add_command_to_reveal_a_file.lua"],
    }).then((nvim) => {
      cy.contains("Hello")
      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open
      assertYaziIsReady(nvim)

      // file2.txt should be selected
      isFileSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)

      // select file2, the cursor moves one line down to the next file
      cy.typeIntoTerminal(" ")
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)

      // also select the next file because multiple files have to be selected
      isFileSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)
      cy.typeIntoTerminal(" ")
      isFileNotSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)
      cy.typeIntoTerminal("{control+q}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // items in the quickfix list should now be visible
      cy.contains(`${nvim.dir.contents["file2.txt"].name}|1 col 1|`)
      cy.contains(`${nvim.dir.contents["file3.txt"].name}|1 col 1|`)
    })
  })
})
