import assert from "assert"
import type { MyTestDirectoryFile } from "MyTestDirectory"
import path from "path"
import { z } from "zod"
import {
  assertYaziIsHovering,
  hoverFileAndVerifyItsHovered,
} from "./utils/hover-utils"
import { assertNeovimCwd } from "./utils/neovim-utils"
import {
  assertYaziIsReady,
  isFileNotSelectedInYazi,
  isFileSelectedInYazi,
} from "./utils/yazi-utils"

describe("opening files", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can display yazi in a floating terminal", () => {
    cy.startNeovim().then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")

      // yazi should now be visible, showing the names of adjacent files
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
    })
  })

  it("can display yazi fullscreen", () => {
    cy.startNeovim({}).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // normally, when yazi is started, a message is shown at the bottom
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("-- TERMINAL --")
      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")

      // load a config-modification that makes yazi fullscreen
      nvim.runExCommand({
        command: `luafile ${"config-modifications/yazi_config/make_yazi_fullscreen.lua" satisfies MyTestDirectoryFile}`,
      })

      cy.typeIntoTerminal("{upArrow}")

      // yazi should now be covering the entire screen
      cy.contains("-- TERMINAL --").should("not.exist")
    })
  })

  it("can open a file that was selected in yazi", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      cy.contains(nvim.dir.contents["file2.txt"].name)

      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      cy.typeIntoTerminal("{enter}")

      // the file content should now be visible
      cy.contains("Hello 👋")
    })
  })

  it("can open yazi and hover a filename selected in visual mode", () => {
    cy.startNeovim().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      function getSelectedFilePath(): Cypress.Chainable<string> {
        const filenameSchema = z.object({ filename: z.string() })
        return cy
          .nvim_runLuaCode({
            luaCode: `return require("yazi.utils").selected_file_path()`,
          })
          .then((result) => {
            const value = filenameSchema.parse(result.value)
            return value.filename satisfies string
          })
      }

      // add text that contains a filename in the middle to test that limiting
      // the recognition of the filename works
      //
      // use a complicated filename to test that the filename is recognized
      // even in these cases
      nvim.runLuaCode({
        luaCode: `vim.api.nvim_buf_set_lines(0, 0, -1, false, {"aaaaaa./dir with spaces/file2.txt__aaaaaaaa"})`,
      })

      // select the file name only
      cy.typeIntoTerminal("_f.vt_")

      getSelectedFilePath().should(
        "match",
        new RegExp("dir with spaces/file2.txt" satisfies MyTestDirectoryFile),
      )

      // add text that contains a filename delimited with spaces to test that
      // extra spaces are ignored
      nvim.runLuaCode({
        luaCode: `vim.api.nvim_buf_set_lines(0, 0, -1, false, {" ./dir with spaces/file2.txt "})`,
      })
      cy.typeIntoTerminal(
        // this time select the entire line, including the spaces
        "V",
      )
      getSelectedFilePath().should(
        "match",
        new RegExp("dir with spaces/file2.txt" satisfies MyTestDirectoryFile),
      )
    })
  })

  it("can open a file in a vertical split", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
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
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      hoverFileAndVerifyItsHovered(nvim, "file2.txt")
      isFileSelectedInYazi(nvim.dir.contents["file2.txt"].name)
      cy.typeIntoTerminal("{control+x}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // the file path must be visible at the bottom
      cy.contains(nvim.dir.contents["file2.txt"].name)
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
    })
  })

  describe("opening files in new tabs", () => {
    it("can open a file in a new tab", () => {
      cy.startNeovim({
        startupScriptModifications: [
          "add_yazi_context_assertions.lua",
          "add_command_to_reveal_a_file.lua",
        ],
      }).then((nvim) => {
        cy.contains("If you see this text, Neovim is ready!")

        cy.typeIntoTerminal("{upArrow}")
        assertYaziIsReady(nvim)

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

    it("preserves line numbers for new tabs", () => {
      // a regression reported in
      // https://github.com/mikavilpas/yazi.nvim/issues/649
      cy.visit("/")
      cy.startNeovim({}).then((nvim) => {
        nvim.runExCommand({ command: "set number" })
        nvim.runLuaCode({
          luaCode: `assert(vim.o.number == true, "line numbers are not set")`,
        })

        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")

        // open and close yazi without doing anything. This used to remove line
        // numbering in the new tab, when a previous buffer was switched to
        cy.typeIntoTerminal("{upArrow}")
        cy.contains("config-modifications" satisfies MyTestDirectoryFile)
        cy.typeIntoTerminal("q")
        cy.contains("config-modifications").should("not.exist")

        nvim.runExCommand({ command: "tabedit %:p:h/file2.txt" })
        nvim.runExCommand({ command: "buffer 1" })

        cy.contains("If you see this text, Neovim is ready!")
        nvim.runLuaCode({
          luaCode: `assert(vim.o.number == true, "line numbers are not set")`,
        })
      })
    })
  })

  it("can send file names to the quickfix list", () => {
    cy.startNeovim({
      filename: "file2.txt",
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
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

  it("can open yazi with the files in the quickfix list", () => {
    cy.startNeovim({
      filename: "file2.txt",
      startupScriptModifications: [
        "yazi_config/open_multiple_files.lua",
        "add_yazi_context_assertions.lua",
      ],
    }).then((nvim) => {
      cy.contains("Hello")

      // add some files to the quickfix list
      nvim.runLuaCode({
        luaCode: `vim.fn.setqflist({{filename = "file2.txt"}, {filename = "file3.txt"}})`,
      })

      // show the quickfix list
      nvim.runLuaCode({ luaCode: `vim.api.nvim_command('copen')` })
      cy.contains("file3.txt||")

      // focus the quickfix list
      nvim.runLuaCode({ luaCode: `vim.api.nvim_command('wincmd j')` })

      // open yazi. It should open two tabs, one for each file in the quickfix
      // list
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      isFileSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      isFileNotSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)

      // switch to the next yazi tab. This should select the other file
      cy.typeIntoTerminal("]")
      isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
      isFileSelectedInYazi("file3.txt" satisfies MyTestDirectoryFile)
    })
  })

  describe("bulk renaming", () => {
    it("can bulk rename files", () => {
      cy.startNeovim().then(() => {
        cy.contains("If you see this text, Neovim is ready!")
        // in yazi, bulk renaming is done by
        // - selecting files and pressing "r".
        // - It opens the editor with the names of the selected files.
        // - Next, the editor must make changes to the file names and save the
        //   file.
        // - Finally, yazi should rename the files to match the new names.
        cy.typeIntoTerminal("{upArrow}")

        isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
        cy.typeIntoTerminal("{control+a}r")

        // yazi should now have opened an embedded Neovim. The file name should say
        // "bulk" somewhere to indicate this
        cy.contains(new RegExp("yazi-\\d+/bulk-\\d+"))

        // edit the name of the first file
        cy.typeIntoTerminal("xxx")
        cy.typeIntoTerminal(":xa{enter}")

        // yazi must now ask for confirmation
        cy.contains("Continue to rename? (y/N):")

        // answer yes
        cy.typeIntoTerminal("y{enter}")
        cy.contains("fig-modifications")
      })
    })

    it("can rename a buffer that's open in Neovim", () => {
      cy.startNeovim({
        startupScriptModifications: ["add_yazi_context_assertions.lua"],
      }).then((nvim) => {
        cy.contains("If you see this text, Neovim is ready!")
        cy.typeIntoTerminal("{upArrow}")
        assertYaziIsReady(nvim)
        isFileNotSelectedInYazi("file2.txt" satisfies MyTestDirectoryFile)
        // select only the current file to make the test easier
        cy.typeIntoTerminal("v")
        cy.typeIntoTerminal("r") // start renaming

        // yazi should now have opened an embedded Neovim. The file name should say
        // "bulk" somewhere to indicate this
        cy.contains(new RegExp("yazi-\\d+/bulk-\\d+"))

        // edit the name of the file
        cy.typeIntoTerminal("cc")
        cy.typeIntoTerminal("renamed-file.txt{esc}")
        cy.typeIntoTerminal(":xa{enter}")

        // yazi must now ask for confirmation
        cy.contains("Continue to rename? (y/N):")

        // answer yes
        cy.typeIntoTerminal("y{enter}")

        // close yazi
        cy.contains("-- TERMINAL --")
        cy.typeIntoTerminal("q")
        cy.contains("-- TERMINAL --").should("not.exist")

        // the file should now be renamed - ask neovim to confirm this
        nvim.runExCommand({ command: "ls" }).and((result) => {
          expect(result.value).to.contain("renamed-file.txt")
        })
      })
    })
  })

  it("can open files with complex characters in their name", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)

      hoverFileAndVerifyItsHovered(nvim, "routes/posts.$postId/route.tsx")
      cy.typeIntoTerminal("{enter}")

      // close yazi just to be sure the file preview is not found instead
      cy.get(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      ).should("not.exist")

      // the file contents should now be visible
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")
    })
  })

  it("can copy the relative path to the initial file", () => {
    // the copied path should be relative to the file/directory yazi was
    // started in (the initial file)

    cy.startNeovim({
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      hoverFileAndVerifyItsHovered(
        nvim,
        "routes/posts.$postId/adjacent-file.txt",
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
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      assertYaziIsReady(nvim)
      cy.contains(nvim.dir.contents["file2.txt"].name)

      // enter another directory and select a file
      hoverFileAndVerifyItsHovered(
        nvim,
        "routes/posts.$postId/adjacent-file.txt",
      )
      // select all files
      cy.typeIntoTerminal("{control+a}")

      // copy the relative paths to the selected files
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

  it("can open multiple files in a directory whose name contains a space character", () => {
    cy.startNeovim({ filename: "dir with spaces/file1.txt" }).then((nvim) => {
      cy.contains("this is the first file")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        nvim.dir.contents["dir with spaces"].contents["file2.txt"].name,
      )

      // select all files and open them
      cy.typeIntoTerminal("{control+a}")
      cy.typeIntoTerminal("{enter}")

      nvim.runExCommand({ command: "buffers" }).then((result) => {
        expect(result.value).to.match(
          new RegExp("dir with spaces/file1.txt" satisfies MyTestDirectoryFile),
        )
        expect(result.value).to.match(
          new RegExp("dir with spaces/file2.txt" satisfies MyTestDirectoryFile),
        )
      })
    })
  })

  it("can open multiple open files in yazi tabs", () => {
    cy.startNeovim({
      filename: {
        openInVerticalSplits: [
          "initial-file.txt",
          "file2.txt",
          "dir with spaces/file1.txt",
        ],
      },
      startupScriptModifications: ["yazi_config/open_multiple_files.lua"],
    }).then((nvim) => {
      cy.contains("Hello")

      // now that multiple files are open, and the configuration has been set
      // to open multiple files in yazi tabs, opening yazi should show the
      // tabs
      cy.typeIntoTerminal("{upArrow}")

      // this is the first yazi tab (1)
      isFileSelectedInYazi(nvim.dir.contents["initial-file.txt"].name)
      isFileNotSelectedInYazi(nvim.dir.contents["file2.txt"].name)

      // next, move to the second tab (2)
      cy.typeIntoTerminal("2")
      isFileSelectedInYazi(nvim.dir.contents["file2.txt"].name)
      isFileNotSelectedInYazi(nvim.dir.contents["initial-file.txt"].name)

      // next, move to the third tab (3). This tab should be in a different
      // directory, so other adjacent files should be visible than before
      cy.typeIntoTerminal("3")
      cy.contains(
        nvim.dir.contents["dir with spaces"].contents["file1.txt"].name,
      )
      isFileSelectedInYazi(
        nvim.dir.contents["dir with spaces"].contents["file1.txt"].name,
      )
      isFileNotSelectedInYazi(
        nvim.dir.contents["dir with spaces"].contents["file2.txt"].name,
      )
    })
  })
})

describe("opening files from visual mode", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can open a relative file", () => {
    cy.startNeovim({
      filename: "dir with spaces/file1.txt",
      startupScriptModifications: [
        "add_yazi_context_assertions.lua",
        "add_command_to_reveal_a_file.lua",
      ],
    }).then((nvim) => {
      cy.contains("this is the first file")

      // enter a relative file path
      cy.typeIntoTerminal("cc./file2.txt{esc}")
      cy.typeIntoTerminal("V{upArrow}")
      assertYaziIsReady(nvim)

      // wait for yazi to open. it should have the correct file selected, and
      // the file's contents should be visible in the preview pane in yazi.
      assertYaziIsHovering(nvim, "dir with spaces/file2.txt")
      cy.contains("this is the second file")

      // Open the file and verify that the correct file was opened.
      cy.typeIntoTerminal("{enter}")

      nvim.runLuaCode({ luaCode: `return vim.fn.bufname()` }).then((result) => {
        // A regression might open the file from the test environment blueprint
        // directory instead of from inside the unique test environment for this
        // very test. Better to check that does not happen.
        expect(result.value).to.contain(nvim.dir.testEnvironmentPathRelative)
        expect(result.value).to.contain(
          "dir with spaces/file2.txt" satisfies MyTestDirectoryFile,
        )
      })
    })
  })

  it("can open an absolute file path", () => {
    cy.startNeovim().then((nvim) => {
      cy.contains("If you see this text, Neovim is ready!")

      // enter a relative file path
      cy.typeIntoTerminal("dd")
      const filepath = nvim.dir.rootPathAbsolute + "/dir with spaces/file2.txt"

      // make sure the path points to the unique test environment for this test
      assert(filepath.includes("testdirs/dir-"))
      nvim.runLuaCode({
        luaCode: `vim.api.nvim_command('normal! i${filepath}')`,
      })
      cy.typeIntoTerminal("V{upArrow}")

      // wait for yazi to open. it should have the correct file selected, and
      // the file's contents should be visible in the preview pane in yazi.
      cy.contains("this is the second file")

      // Open the file and verify that the correct file was opened.
      cy.typeIntoTerminal("{enter}")

      nvim.runLuaCode({ luaCode: `return vim.fn.bufname()` }).then((result) => {
        // A regression might open the file from the test environment blueprint
        // directory instead of from inside the unique test environment for this
        // very test. Better to check that does not happen.
        expect(result.value).to.contain(nvim.dir.testEnvironmentPathRelative)
        expect(result.value).to.contain(
          "dir with spaces/file2.txt" satisfies MyTestDirectoryFile,
        )
      })
    })
  })

  it("can open the log file with `:Yazi logs`", () => {
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      nvim.runExCommand({ command: "Yazi logs" })

      nvim.runExCommand({ command: "buffers" }).and((result) => {
        expect(result.value).to.contain("test-environment/.repro/yazi.log")
      })
    })
  })
})

describe("changing the change_neovim_cwd_on_close", () => {
  it("can change the cwd if no files are selected", () => {
    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: ["add_yazi_context_assertions.lua"],
      filename: "subdirectory/subdirectory-file.txt",
    }).then((nvim) => {
      cy.contains("Hello from the subdirectory!")

      assert(nvim.dir.testEnvironmentPath.endsWith("/"))
      const startPath = nvim.dir.testEnvironmentPath.slice(0, -1)

      // verify the pwd does not change without enabling the setting
      assertNeovimCwd(nvim, startPath)
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("-- TERMINAL --")
      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")
      assertNeovimCwd(nvim, startPath)

      // allow change_neovim_cwd_on_close, which makes the pwd change
      nvim.doFile({
        luaFile:
          "config-modifications/yazi_config/enable_change_neovim_cwd_on_close.lua",
      })

      // verify the pwd changes
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("-- TERMINAL --")
      cy.typeIntoTerminal("q")
      cy.contains("-- TERMINAL --").should("not.exist")
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
