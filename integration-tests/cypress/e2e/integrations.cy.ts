import { flavors } from "@catppuccin/palette"
import assert from "assert"
import type { MyTestDirectoryFile } from "MyTestDirectory"
import {
  assertYaziIsHovering,
  hoverFileAndVerifyItsHovered,
} from "./utils/hover-utils"
import { textIsVisibleWithBackgroundColor } from "./utils/text-utils"
import { assertYaziIsReady } from "./utils/yazi-utils"

describe("grug-far integration (search and replace)", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use grug-far.nvim to search and replace in the directory of the hovered file", () => {
    cy.startNeovim({
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
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vj")
      cy.typeIntoTerminal("{control+g}")

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

describe("telescope integration (search)", () => {
  // https://github.com/nvim-telescope/telescope.nvim
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use telescope.nvim to search in the current directory", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      cy.typeIntoTerminal("{control+s}")

      cy.contains(new RegExp(`Grep in testdirs/.*?/routes/posts.\\$postId`))

      // verify this manually for now as I'm a bit scared this will be too
      // flaky
    })
  })

  it("can use telescope.nvim to search, limited to the selected files only", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vj")
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

describe("fzf-lua integration (grep)", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use fzf-lua.nvim to search in the current directory", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
      startupScriptModifications: ["yazi_config/use_fzf_lua.lua"],
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      cy.typeIntoTerminal("{control+s}")

      // wait for fzf-lua to be visible
      cy.contains("to Fuzzy Search")

      cy.typeIntoTerminal("this")

      // results should be visible
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      )

      // results from outside the directory should not be visible. This
      // verifies the search is limited to the current directory
      cy.contains(nvim.dir.contents["initial-file.txt"].name).should(
        "not.exist",
      )
    })
  })

  it("can use fzf-lua.nvim to search, limited to the selected files only", () => {
    // https://github.com/ibhagwan/fzf-lua
    cy.startNeovim({
      filename: "routes/posts.$postId/route.tsx",
      startupScriptModifications: [
        "yazi_config/use_fzf_lua.lua",
        "add_yazi_context_assertions.lua",
      ],
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      // wait until the file contents are visible
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vk")
      cy.typeIntoTerminal("{control+s}")

      // fzf-lua should be open now
      cy.contains("to Fuzzy Search")

      // search for some file content. This should match
      // ../../../test-environment/routes/posts.$postId/adjacent-file.txt
      cy.typeIntoTerminal("this", { delay: 30 })

      // some results should be visible
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")

      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      ).should("not.exist")
    })
  })
})

describe("snacks.picker integration (grep)", () => {
  // https://github.com/folke/snacks.nvim

  it("can use snacks.picker to search, limited to the selected files only", () => {
    cy.visit("/")
    cy.startNeovim({
      filename: "routes/posts.$postId/route.tsx",
      startupScriptModifications: [
        "yazi_config/use_snacks_picker.lua",
        "add_yazi_context_assertions.lua",
      ],
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      // wait until the file contents are visible
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      assertYaziIsHovering(nvim, "routes/posts.$postId/route.tsx")

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vk")
      cy.typeIntoTerminal("{control+s}")

      // wait until the snacks.picker is visible
      cy.contains("Grep")
      cy.contains("0/0")

      // snacks.picker should have started in insert mode
      nvim.runLuaCode({ luaCode: `return vim.fn.mode()` }).should((result) => {
        expect(result.value).to.equal("i")
      })

      // verify that the picker shows the correct title
      cy.contains("Grep in 2 paths")

      // snacks.picker should be open now. Don't test it for now because it
      // might be unstable. If you want to try it manually, you can verify
      // that it does not find the text in should-be-excluded-file
    })
  })

  it("can optionally setup a keybinding to copy the relative paths to files", () => {
    cy.visit("/")
    cy.startNeovim({
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      // wait until the file contents are visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("dd")

      // open the snacks.picker
      cy.typeIntoTerminal("  ")
      cy.contains("Smart")

      cy.typeIntoTerminal("dir with spaces")

      // select both files
      cy.contains("file1.txt")
      cy.contains("file2.txt")
      cy.typeIntoTerminal("{control+i}{control+i}")

      // press the keybinding to copy the relative paths
      cy.typeIntoTerminal("{control+y}")

      // paste the contents of the clipboard into the buffer so that it's
      // slightly easier to debug visually
      cy.typeIntoTerminal("p")
      cy.contains("Smart").should("not.exist")

      // verify that the clipboard register contains the relative paths
      nvim
        .runLuaCode({ luaCode: `return vim.fn.getreg('"')` })
        .then((result) => {
          const value = result.value?.valueOf()
          assert(typeof value === "string")
          expect(value.split("\n")).to.eql([
            "../../dir with spaces/file1.txt",
            "../../dir with spaces/file2.txt",
          ])
        })
    })
  })
})

describe("snacks open_and_pick_window integration", () => {
  it("can open a file in a specific split window", () => {
    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
      NVIM_APPNAME: "nvim_integrations",
    }).then((nvim) => {
      nvim.runExCommand({ command: "vsplit" })
      cy.typeIntoTerminal("{upArrow}")

      const file = "routes/posts.$postId/adjacent-file.txt"
      hoverFileAndVerifyItsHovered(nvim, file)
      cy.typeIntoTerminal("{control+o}")

      // wait until the picker is showing labels for the splits. They will be
      // labeled "a" and "s", and will have a particular background color
      textIsVisibleWithBackgroundColor("s", flavors.macchiato.colors.peach.rgb)

      cy.typeIntoTerminal("s")
      nvim.runExCommand({ command: "buffers" }).and((result) => {
        expect(result.value).to.contain("adjacent-file.txt")
      })
    })
  })
})
