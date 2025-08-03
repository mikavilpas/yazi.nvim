import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import { textIsVisibleWithBackgroundColor } from "@tui-sandbox/library/dist/src/client/cypress-assertions"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/src/server/types"
import type { NeovimContext } from "cypress/support/tui-sandbox"

const darkTheme = flavors.macchiato.colors

export function isFileSelectedInYazi(text: string): void {
  textIsVisibleWithBackgroundColor(text, rgbify(darkTheme.text.rgb))
}

export function isDirectorySelectedInYazi(text: string): void {
  textIsVisibleWithBackgroundColor(text, rgbify(darkTheme.blue.rgb))
}

export function isFileNotSelectedInYazi(text: string): void {
  textIsVisibleWithBackgroundColor(text, rgbify(darkTheme.base.rgb))
}

export function assertYaziIsReady(
  nvim: NeovimContext,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.waitForLuaCode({ luaAssertion: `Yazi_is_ready()` })
}
