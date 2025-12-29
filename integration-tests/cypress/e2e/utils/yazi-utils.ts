import { flavors } from "@catppuccin/palette"
import { rgbify, textIsVisibleWithBackgroundColor } from "@tui-sandbox/library"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/server"
import type { MyTestDirectoryFile } from "../../../MyTestDirectory"
import type { NeovimContext } from "../../support/tui-sandbox"

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

export function isFileFoundInYazi(filename: MyTestDirectoryFile): void {
  textIsVisibleWithBackgroundColor(
    filename,
    rgbify(flavors.macchiato.colors.yellow.rgb),
  )
}

/** find a directory and wait for yazi to have found it, then select it */
export function findFileInYazi(filename: MyTestDirectoryFile): void {
  cy.typeIntoTerminal("/")
  cy.contains("Find next:")
  cy.typeIntoTerminal(filename)
  isFileFoundInYazi(filename)
}

export function assertYaziIsReady(
  nvim: NeovimContext,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.waitForLuaCode({ luaAssertion: `Yazi_is_ready()` })
}
