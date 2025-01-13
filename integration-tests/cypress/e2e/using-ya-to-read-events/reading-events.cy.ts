import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { MyTestDirectoryFile } from "MyTestDirectory"

describe("reading events", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can read 'cd' events and use telescope in the latest directory", () => {
    cy.startNeovim()
    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")
    // start yazi
    cy.typeIntoTerminal("{upArrow}")

    // move to the parent directory. This should make yazi send the "cd" event,
    // indicating that the directory was changed
    cy.contains("subdirectory")
    cy.typeIntoTerminal("/subdirectory{enter}")
    cy.typeIntoTerminal("{rightArrow}")
    cy.typeIntoTerminal("{control+s}")

    // telescope should now be visible. Let's search for the contents of the
    // file, which we know beforehand
    cy.contains("Grep in")
    cy.typeIntoTerminal("This")

    // we should see text indicating the search is limited to the current
    // directory
    cy.contains("This is other-sub-file.txt")
  })

  it("can read 'trash' events and close an open buffer when its file was trashed", () => {
    // NOTE: trash means moving a file to the trash, not deleting it permanently

    cy.startNeovim({
      filename: { openInVerticalSplits: ["initial-file.txt", "file2.txt"] },
    }).then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")
      cy.contains("Hello")

      // modify the buffer to make sure it works even if the buffer is modified
      cy.typeIntoTerminal("ccchanged{esc}")

      // start yazi and wait for it to display contents
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("subdirectory" satisfies MyTestDirectoryFile)

      // start file deletion
      cy.typeIntoTerminal("d")
      cy.contains("Trash 1 selected file?")
      cy.typeIntoTerminal("y")

      cy.get("Move 1 selected file to trash").should("not.exist")

      // close yazi
      cy.typeIntoTerminal("q")

      // internally, we should have received a trash event from yazi, and yazi.nvim should
      // have closed the buffer
      cy.contains(nvim.dir.contents["initial-file.txt"].name).should(
        "not.exist",
      )
      cy.contains("If you see this text, Neovim is ready").should("not.exist")

      // make sure two windows are open. The test environment uses snacks.nvim
      // which should make sure the window layout is preserved when closing
      // the deleted buffer. The default in neovim is to also close the
      // window.
      nvim.runExCommand({ command: `echo winnr("$")` }).then((result) => {
        expect(result.value).to.match(/2/)
      })
    })
  })

  it("can read 'delete' events and close an open buffer when its file was deleted", () => {
    // NOTE: delete means permanently deleting a file (not moving it to the trash)

    cy.startNeovim({
      filename: { openInVerticalSplits: ["initial-file.txt", "file2.txt"] },
    }).then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")
      cy.contains("Hello")

      // make sure If you see this text, Neovim is ready! is in the correct
      // buffer so that we are editing the correct buffer in this test
      nvim.runExCommand({ command: "echo expand('%')" }).then((result) => {
        expect(result.value).to.match(/initial-file.txt$/)
      })

      // modify the buffer to make sure it works even if the buffer is modified
      cy.typeIntoTerminal("ccchanged{esc}")

      // start yazi and wait for it to display contents
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("subdirectory" satisfies MyTestDirectoryFile)

      // start file deletion
      cy.typeIntoTerminal("D")
      cy.contains("Permanently delete 1 selected file?")
      cy.typeIntoTerminal("y")

      cy.get("Delete 1 selected file permanently").should("not.exist")

      // close yazi
      cy.typeIntoTerminal("q")

      // internally, we should have received a delete event from yazi, and yazi.nvim should
      // have closed the buffer
      cy.get(nvim.dir.contents["initial-file.txt"].name).should("not.exist")
      cy.contains("If you see this text, Neovim is ready").should("not.exist")

      // make sure two windows are open. The test environment uses snacks.nvim
      // which should make sure the window layout is preserved when closing
      // the deleted buffer. The default in neovim is to also close the
      // window.
      nvim.runExCommand({ command: `echo winnr("$")` }).then((result) => {
        expect(result.value).to.match(/2/)
      })
    })
  })
})

describe("'rename' events", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can read 'rename' events and update the buffer name when the file was renamed", () => {
    cy.startNeovim().then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi and wait for the current file to be highlighted
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(nvim.dir.contents["initial-file.txt"].name).should(
        "have.css",
        "background-color",
        rgbify(flavors.macchiato.colors.text.rgb),
      )

      // start file renaming
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")

      cy.get("Rename").should("not.exist")

      // yazi should be showing the new file name
      const newFileName = `initial-file2.txt`
      cy.contains(newFileName)

      // close yazi
      cy.typeIntoTerminal("q")

      // the buffer name should now be updated
      cy.contains(newFileName)

      // the file should be saveable
      cy.typeIntoTerminal(":w{enter}")
      cy.contains("E13").should("not.exist")
    })
  })

  it("can rename twice and keep track of the correct file name", () => {
    cy.startNeovim().then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // start file renaming
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")

      cy.get("Rename").should("not.exist")

      // yazi should be showing the new file name
      const newFileName = "initial-file2.txt"
      cy.contains(newFileName)

      // close yazi
      cy.typeIntoTerminal("q")

      // the buffer name should now be updated
      cy.contains(newFileName)

      // rename a second time, returning to the original name
      cy.typeIntoTerminal("{upArrow}")
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("{backspace}")
      cy.contains(newFileName)
      cy.typeIntoTerminal("{enter}")

      cy.typeIntoTerminal("q")
      cy.contains(newFileName).should("not.exist")
    })
  })

  it("can publish YaziRenamedOrMoved events when a file is renamed", () => {
    cy.startNeovim({
      startupScriptModifications: ["notify_rename_events.lua"],
    }).then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi and wait for it to be ready
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("config-modifications" satisfies MyTestDirectoryFile)

      // start file renaming
      cy.typeIntoTerminal("r")
      cy.contains("Rename:")
      cy.typeIntoTerminal("2{enter}")

      cy.get("Rename").should("not.exist")

      // yazi should be showing the new file name
      const newFileName = `initial-file2.txt`
      cy.contains(newFileName)

      // close yazi
      cy.typeIntoTerminal("q")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      nvim
        .runLuaCode({ luaCode: `return _G.yazi_test_events` })
        .should((result) => {
          const events = result.value as unknown[]
          expect(events).to.have.length(1)
        })
    })
  })

  it("reports the correct last_directory when yazi is closed", () => {
    cy.startNeovim({
      startupScriptModifications: [
        "modify_yazi_config_log_yazi_closed_successfully.lua",
      ],
    }).then((nvim) => {
      // the default file should already be open
      cy.contains(nvim.dir.contents["initial-file.txt"].name)
      cy.contains("If you see this text, Neovim is ready!")

      // start yazi and wait for it to be ready
      cy.typeIntoTerminal("{upArrow}")
      cy.contains("config-modifications" satisfies MyTestDirectoryFile)

      // move to another directory
      cy.typeIntoTerminal(
        `/${"dir with spaces" satisfies MyTestDirectoryFile}{enter}`,
      )
      cy.typeIntoTerminal("{rightArrow}")
      cy.contains("this is the first file")

      // close yazi
      cy.typeIntoTerminal("q")

      // yazi should now be closed
      cy.contains("-- TERMINAL --").should("not.exist")

      nvim
        .runLuaCode({
          luaCode: `return _G.yazi_closed_successfully_hook_test_results`,
        })
        .should((result) => {
          debugger
          assert(result.value)
          assert(typeof result.value === "object")
          // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-explicit-any
          const data = result.value as any
          // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
          expect(data["last_directory"]).to.match(/dir with spaces$/)
        })
    })
  })

  describe("custom YaziDDSCustom events", () => {
    it("emits events the user has subscribed to", () => {
      cy.startNeovim({
        startupScriptModifications: ["notify_custom_events.lua"],
      }).then((nvim) => {
        // The user can set a config option to specify custom yazi dds events that
        // they want to subscribe to. These are emitted as YaziDDSCustom events.
        cy.contains("If you see this text, Neovim is ready!")
        cy.typeIntoTerminal("{upArrow}")
        cy.contains(nvim.dir.contents["file2.txt"].name)

        // publish the custom MyMessageNoData event that we subscribed to in
        // notify_custom_events.lua
        cy.typeIntoTerminal("{control+p}")

        // also publish MyMessageWithData that contains json data
        cy.typeIntoTerminal("{control+h}")

        cy.typeIntoTerminal("q")
        cy.contains(nvim.dir.contents["file2.txt"].name).should("not.exist")
        nvim.runExCommand({ command: "messages" }).should((result) => {
          expect(result.value).to.match(
            /Just received a YaziDDSCustom event 'MyMessageNoData'!/,
          )
          expect(result.value).to.match(
            /Just received a YaziDDSCustom event 'MyMessageWithData'!/,
          )
          expect(result.value).to.match(/somedata/)
        })
      })
    })
  })
})
