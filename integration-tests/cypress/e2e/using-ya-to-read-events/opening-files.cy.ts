import {
  isFileNotSelectedInYazi,
  isFileSelectedInYazi,
} from "./utils/yazi-utils"

describe("opening files", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can display yazi in a floating terminal", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")

      // yazi should now be visible, showing the names of adjacent files
      cy.contains(dir.contents["test-setup.lua"].name) // an adjacent file
    })
  })

  it("can open a file that was selected in yazi", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["file.txt"].name)

      // search for the file in yazi. This focuses the file in yazi
      cy.typeIntoTerminal("gg/file.txt{enter}")
      cy.typeIntoTerminal("{enter}")

      // the file content should now be visible
      cy.contains("Hello 👋")
    })
  })

  it("can open a file in a vertical split", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.typeIntoTerminal("/test-setup.lua{enter}")
      cy.typeIntoTerminal("{control+v}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // the file path must be visible at the bottom
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.contains(dir.contents["initial-file.txt"].name)
    })
  })

  it("can open a file in a horizontal split", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.typeIntoTerminal("/test-setup.lua{enter}")
      cy.typeIntoTerminal("{control+x}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // the file path must be visible at the bottom
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.contains(dir.contents["initial-file.txt"].name)
    })
  })

  it("can open a file in a new tab", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)
      cy.typeIntoTerminal("/test-setup.lua{enter}")
      cy.typeIntoTerminal("{control+t}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      cy.contains("defines how to")
      cy.typeIntoTerminal(":tabnext{enter}")

      cy.contains("If you see this text, Neovim is ready!")

      cy.contains(dir.contents["test-setup.lua"].name)
      cy.contains(dir.contents["initial-file.txt"].name)
    })
  })

  it("can send file names to the quickfix list", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")

      // wait for yazi to open
      cy.contains(dir.contents["test-setup.lua"].name)

      // select the initial file, the cursor moves one line down to the next file
      cy.typeIntoTerminal(" ")
      // also select the next file because multiple files have to be selected
      cy.typeIntoTerminal(" ")
      cy.typeIntoTerminal("{control+q}")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      // items in the quickfix list should now be visible
      cy.contains(`${dir.contents["initial-file.txt"].name}||`)
    })
  })

  describe("bulk renaming", () => {
    it("can bulk rename files", () => {
      cy.startNeovim().then((dir) => {
        cy.contains("If you see this text, Neovim is ready!")
        // in yazi, bulk renaming is done by
        // - selecting files and pressing "r".
        // - It opens the editor with the names of the selected files.
        // - Next, the editor must make changes to the file names and save the
        //   file.
        // - Finally, yazi should rename the files to match the new names.
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(dir.contents["test-setup.lua"].name)
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
      cy.startNeovim().then((dir) => {
        cy.contains("If you see this text, Neovim is ready!")
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(dir.contents["test-setup.lua"].name)
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
        cy.typeIntoTerminal("q")

        // the file should now be renamed - ask neovim to confirm this
        cy.typeIntoTerminal(":buffers{enter}")

        cy.contains("renamed-file.txt")
      })
    })
  })

  it("can open files with complex characters in their name", () => {
    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("{upArrow}")

      // enter the routes/ directory
      cy.contains("routes")
      cy.typeIntoTerminal("/routes{enter}")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ) // file in the directory

      // enter routes/posts.$postId/
      cy.typeIntoTerminal("{rightArrow}")

      // select route.tsx
      cy.typeIntoTerminal(
        `/${dir.contents.routes.contents["posts.$postId"].contents["route.tsx"].name}{enter}`,
      )

      // open the file
      cy.typeIntoTerminal("{enter}")

      // close yazi just to be sure the file preview is not found instead
      cy.get(
        dir.contents.routes.contents["posts.$postId"].contents[
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

    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)

      // enter another directory and select a file
      cy.typeIntoTerminal("/routes{enter}")
      cy.contains("posts.$postId")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ) // file in the directory
      cy.typeIntoTerminal("{rightArrow}")
      cy.typeIntoTerminal(
        `/${
          dir.contents.routes.contents["posts.$postId"].contents[
            "adjacent-file.txt"
          ].name
        }{enter}`,
      )

      // the file contents should now be visible
      cy.contains("this file is adjacent-file.txt")

      cy.typeIntoTerminal("{control+y}")

      // yazi should now be closed
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ).should("not.exist")

      // the relative path should now be in the clipboard. Let's paste it to
      // the file to verify this.
      // NOTE: the test-setup configures the `"` register to be the clipboard
      cy.typeIntoTerminal("o{enter}{esc}")
      cy.typeIntoTerminal(':normal ""p{enter}')

      cy.contains("routes/posts.$postId/adjacent-file.txt")
    })
  })

  it("can copy the relative paths of multiple selected files", () => {
    // similarly, the copied path should be relative to the file/directory yazi
    // was started in (the initial file)

    cy.startNeovim().then((dir) => {
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["test-setup.lua"].name)

      // enter another directory and select a file
      cy.typeIntoTerminal("/routes{enter}")
      cy.contains("posts.$postId")
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ) // file in the directory
      cy.typeIntoTerminal("{rightArrow}")
      cy.typeIntoTerminal("{control+a}")

      cy.typeIntoTerminal("{control+y}")

      // yazi should now be closed
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      ).should("not.exist")

      // the relative path should now be in the clipboard. Let's paste it to
      // the file to verify this.
      // NOTE: the test-setup configures the `"` register to be the clipboard
      cy.typeIntoTerminal("o{enter}{esc}")
      cy.typeIntoTerminal(':normal ""p{enter}')

      // all selected files should now be visible
      cy.contains("routes/posts.$postId/adjacent-file.txt")
      cy.contains("routes/posts.$postId/route.tsx")
      cy.contains("routes/posts.$postId/adjacent-file.txt")
    })
  })

  it("can open multiple files in a directory whose name contains a space character", () => {
    cy.startNeovim({ filename: "dir with spaces/file1.txt" }).then((dir) => {
      cy.contains("this is the first file")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(dir.contents["dir with spaces"].contents["file2.txt"].name)

      // select all files and open them
      cy.typeIntoTerminal("{control+a}")
      cy.typeIntoTerminal("{enter}")

      cy.typeIntoTerminal(":buffers{enter}")

      // all files should now be visible
      cy.contains("dir with spaces/file1.txt")
      cy.contains("dir with spaces/file2.txt")
    })
  })

  it("can open multiple open files in yazi tabs", () => {
    cy.startNeovim({
      filename: {
        openInVerticalSplits: [
          "file.txt",
          "test-setup.lua",
          "dir with spaces/file1.txt",
        ],
      },
      startupScriptModifications: [
        "modify_yazi_config_and_open_multiple_files.lua",
      ],
    }).then((dir) => {
      cy.contains("Hello")

      // now that multiple files are open, and the configuration has been set
      // to open multiple files in yazi tabs, opening yazi should show the
      // tabs
      cy.typeIntoTerminal("{upArrow}")

      // this is the first yazi tab (1)
      isFileSelectedInYazi(dir.contents["file.txt"].name)
      isFileNotSelectedInYazi(dir.contents["test-setup.lua"].name)

      // next, move to the second tab (2)
      cy.typeIntoTerminal("2")
      isFileSelectedInYazi(dir.contents["test-setup.lua"].name)
      isFileNotSelectedInYazi(dir.contents["file.txt"].name)

      // next, move to the third tab (3). This tab should be in a different
      // directory, so other adjacent files should be visible than before
      cy.typeIntoTerminal("3")
      cy.contains(dir.contents["dir with spaces"].contents["file1.txt"].name)
      isFileSelectedInYazi(
        dir.contents["dir with spaces"].contents["file1.txt"].name,
      )
      isFileNotSelectedInYazi(
        dir.contents["dir with spaces"].contents["file2.txt"].name,
      )
    })
  })
})
