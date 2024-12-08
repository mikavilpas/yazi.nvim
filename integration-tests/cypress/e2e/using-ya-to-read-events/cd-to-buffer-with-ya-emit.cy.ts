import { isHoveredInNeovim, isNotHoveredInNeovim } from "./utils/hover-utils"

// NOTE: cypress doesn't support the tab key, but control+i seems to work fine
// https://docs.cypress.io/api/commands/type#Typing-tab-key-does-not-work

const yaziText = "NOR"

describe("revealing another open split (buffer) in yazi", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can highlight the buffer when hovered", () => {
    const view = {
      leftFile: { text: "ello from file_1.txt" },
      centerFile: { text: "This is file_2.txt" },
      rightFile: { text: "You are looking at file_3.txt" },
    } as const

    cy.startNeovim({
      filename: {
        openInVerticalSplits: [
          "highlights/file_1.txt",
          "highlights/file_2.txt",
          "highlights/file_3.txt",
        ],
      },
      startupScriptModifications: [
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
        "modify_yazi_config_use_ya_emit.lua",
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

      // start yazi and wait for it to be visible
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(yaziText)

      // Switch to the other buffers' directories in yazi. This should make
      // yazi send a hover event for the new, highlighted file.
      cy.typeIntoTerminal("{control+i}")
      isNotHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("{control+i}")
      isHoveredInNeovim(view.rightFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.leftFile.text)

      cy.typeIntoTerminal("{control+i}")
      isHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

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
        "modify_yazi_config_use_ya_emit.lua",
      ],
    }).then(() => {
      isNotHoveredInNeovim(view.leftAndCenterFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      // start yazi
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(yaziText)

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
