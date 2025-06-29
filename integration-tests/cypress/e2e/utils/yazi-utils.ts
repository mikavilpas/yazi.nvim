import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/src/server/types"
import type { NeovimContext } from "cypress/support/tui-sandbox"

const darkTheme = flavors.macchiato.colors

export function isFileSelectedInYazi(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    rgbify(darkTheme.text.rgb),
  )
}

export function isDirectorySelectedInYazi(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    rgbify(darkTheme.blue.rgb),
  )
}

export function isFileNotSelectedInYazi(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    rgbify(darkTheme.base.rgb),
  )
}

export function assertYaziIsReady(
  nvim: NeovimContext,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.waitForLuaCode({ luaAssertion: `Yazi_is_ready()` })
}
