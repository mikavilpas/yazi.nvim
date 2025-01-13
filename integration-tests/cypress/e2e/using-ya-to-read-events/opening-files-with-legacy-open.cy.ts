import type { MyTestDirectoryFile } from "MyTestDirectory"
import {
  isFileNotSelectedInYazi,
  isFileSelectedInYazi,
} from "./utils/yazi-utils"

describe("opening files with yazi < 0.4.0", () => {
  // versions before this do not support `ya emit open`. Instead, they send a
  // fake <enter> keypress to yazi and react on the file that was opened by
  // yazi. This approach is not very robust because the user might have set a
  // custom enter key - in which case the whole thing does not work.
  //
  // This has been fixed for recent yazi versions by using `ya emit open` to
  // send the file path to yazi. These tests are here until the legacy approach
  // is removed.
  beforeEach(() => {
    cy.visit("/")
  })

  it("can open a file in a vertical split", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      cy.typeIntoTerminal(
        `/${"file2.txt" satisfies MyTestDirectoryFile}{enter}`,
      )
      cy.typeIntoTerminal("{esc}") // hide the search highlight
      isFileSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      cy.typeIntoTerminal("{control+v}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // the file path must be visible at the bottom
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  it("can open a file in a horizontal split", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.typeIntoTerminal(`/${nvim.dir.contents["file2.txt"].name}{enter}`)
      cy.typeIntoTerminal("{esc}") // hide the search highlight
      isFileSelectedInYazi(nvim.dir.contents["file2.txt"].name)
      cy.typeIntoTerminal("{control+x}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // the file path must be visible at the bottom
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  it("can open a file in a new tab", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      isFileNotSelectedInYazi(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.typeIntoTerminal(`/${nvim.dir.contents["file2.txt"].name}{enter}`)
      cy.typeIntoTerminal("{esc}") // hide the search highlight
      isFileSelectedInYazi(nvim.dir.contents["file2.txt"].name)
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

  it("can send file names to the quickfix list", () => {
    cy.startNeovim({
      filename: "file2.txt",
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("Hello")
      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open
      cy.contains(nvim.dir.contents["file2.txt"].name)

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
      cy.contains(`${nvim.dir.contents["file2.txt"].name}||`)
      cy.contains(`${nvim.dir.contents["file3.txt"].name}||`)
    })
  })

  it("can copy the relative path to the initial file", () => {
    // the copied path should be relative to the file/directory yazi was
    // started in (the initial file)

    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)

      // enter another directory and select a file
      cy.typeIntoTerminal("/routes{enter}")
      cy.contains("posts.$postId")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ) // file in the directory
      cy.typeIntoTerminal("{rightArrow}")
      cy.typeIntoTerminal(
        `/${
          nvim.dir.contents.routes.contents["posts.$postId"].contents[
            "adjacent-file.txt"
          ].name
        }{enter}{esc}`,
        // esc to hide the search highlight
      )
      isFileSelectedInYazi(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )

      // the file contents should now be visible
      cy.contains("this file is adjacent-file.txt")

      cy.typeIntoTerminal("{control+y}")

      // yazi should now be closed
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ).should("not.exist")

      // the relative path should now be in the clipboard. Let's paste it to
      // the file to verify this.
      // NOTE: the test-setup configures the `"` register to be the clipboard
      cy.typeIntoTerminal("o{enter}{esc}")
      nvim
        .runLuaCode({ luaCode: `return vim.fn.getreg('"')` })
        .then((result) => {
          expect(result.value).to.contain(
            "routes/posts.$postId/adjacent-file.txt" satisfies MyTestDirectoryFile,
          )
        })
    })
  })

  it("can copy the relative paths of multiple selected files", () => {
    // similarly, the copied path should be relative to the file/directory yazi
    // was started in (the initial file)

    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_do_not_use_ya_emit_open.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(nvim.dir.contents["file2.txt"].name)

      // enter another directory and select a file
      cy.typeIntoTerminal("/routes{enter}")
      cy.contains("posts.$postId")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ) // file in the directory
      cy.typeIntoTerminal("{rightArrow}")
      cy.typeIntoTerminal("{control+a}")

      cy.typeIntoTerminal("{control+y}")

      // yazi should now be closed
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ).should("not.exist")

      // the relative path should now be in the clipboard. Let's paste it to
      // the file to verify this.
      // NOTE: the test-setup configures the `"` register to be the clipboard
      cy.typeIntoTerminal("o{enter}{esc}")
      nvim
        .runLuaCode({ luaCode: `return vim.fn.getreg('"')` })
        .then((result) => {
          expect(result.value).to.eql(
            (
              [
                "routes/posts.$postId/adjacent-file.txt",
                "routes/posts.$postId/route.tsx",
                "routes/posts.$postId/should-be-excluded-file.txt",
              ] satisfies MyTestDirectoryFile[]
            ).join("\n"),
          )
        })
    })
  })
})
