import { isHoveredInNeovim, isNotHoveredInNeovim } from "./utils/hover-utils"

// NOTE: cypress doesn't support the tab key, but control+i seems to work fine
// https://docs.cypress.io/api/commands/type#Typing-tab-key-does-not-work

// TODO make this more robust once we can jump to a file, not just a
// directory - could test with directories that have multiple files

describe("'cd' to another buffer's directory", () => {
  beforeEach(() => {
    cy.visit("http://localhost:5173")
  })

  it("can highlight the buffer when hovered", () => {
    const view = {
      leftFile: { text: "This is other-sub-file.txt" },
      centerFile: { text: "this file is adjacent-file.txt" },
      rightFile: { text: "ello from the subdirectory!" },
    } as const

    cy.startNeovim({
      filename: {
        openInVerticalSplits: [
          "subdirectory/subdirectory-file.txt",
          "routes/posts.$postId/adjacent-file.txt",
          "other-subdirectory/other-sub-file.txt",
        ],
      },
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then(() => {
      // sanity check to make sure the files are open
      cy.contains(view.leftFile.text)
      cy.contains(view.centerFile.text)
      cy.contains(view.rightFile.text)

      // before doing anything, both files should be unhovered (have the
      // default background color)
      isNotHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      // Switch to the other buffers' directories in yazi. This should make
      // yazi send a hover event for the new, highlighted file.
      //
      // Since each directory only has one file, it should be highlighted :)
      cy.typeIntoTerminal("{control+i}")
      isNotHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("{control+i}")
      isHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("{control+i}")
      isNotHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isHoveredInNeovim(view.rightFile.text)

      // tab once more to make sure it wraps around
      cy.typeIntoTerminal("{control+i}")
      isNotHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)
    })
  })

  it("skips highlighting splits for the same file", () => {
    const view = {
      leftAndCenterFile: { text: "ello from the subdirectory!" },
      rightFile: { text: "This is other-sub-file.txt" },
    } as const

    cy.startNeovim({
      filename: {
        openInVerticalSplits: [
          // open the same file in two splits
          "subdirectory/subdirectory-file.txt",
          "subdirectory/subdirectory-file.txt",
          "other-subdirectory/other-sub-file.txt",
        ],
      },
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then(() => {
      isNotHoveredInNeovim(view.leftAndCenterFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      // start yazi
      cy.typeIntoTerminal("{upArrow}")

      cy.typeIntoTerminal("{control+i}")

      // the right file should be highlighted
      isNotHoveredInNeovim(view.leftAndCenterFile.text)
      isHoveredInNeovim(view.rightFile.text)

      // tab again to make sure it wraps around. It should highlight both splits
      cy.typeIntoTerminal("{control+i}")
      isHoveredInNeovim(view.leftAndCenterFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      // tab again. Since the left and center file are the same, it should
      // skip the center file and highlight the right file

      cy.typeIntoTerminal("{control+i}")
      isNotHoveredInNeovim(view.leftAndCenterFile.text)
      isHoveredInNeovim(view.rightFile.text)
    })
  })
})
