import { isHoveredInNeovim, isNotHoveredInNeovim } from "./utils/hover-utils"
import { yaziText } from "./utils/yazi-utils"

// The yazi keymappings need to be defined in the yazi config. The test
// environment contains the mapping in the .config/yazi/keymap.toml file
describe("revealing another open split (buffer) in yazi", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it(`can react to the "NvimCycleBuffer" event`, () => {
    // This event signifies yazi.nvim should cycle_open_buffers, which makes
    // yazi focus the next visible neovim split as the current file.
    //
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
        "add_yazi_context_assertions.lua",
        "modify_yazi_config_and_add_hovered_buffer_background.lua",
      ],
    }).then((nvim) => {
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
      nvim.waitForLuaCode({ luaAssertion: `Yazi_is_ready()` })

      // Switch to the other buffers' directories in yazi. This should make
      // yazi send a hover event for the new, highlighted file.
      //
      cy.typeIntoTerminal("I")
      isNotHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovim(view.rightFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.leftFile.text)

      cy.typeIntoTerminal("I")
      isHoveredInNeovim(view.leftFile.text)
      isNotHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)

      // tab once more to make sure it wraps around
      cy.typeIntoTerminal("I")
      isNotHoveredInNeovim(view.leftFile.text)
      isHoveredInNeovim(view.centerFile.text)
      isNotHoveredInNeovim(view.rightFile.text)
    })
  })
})
