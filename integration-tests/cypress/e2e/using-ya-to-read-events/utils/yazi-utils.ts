import { flavors } from "@catppuccin/palette"
import { rgbify } from "./hover-utils"

const darkTheme = flavors.macchiato.colors

export function isFileSelectedInYazi(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    rgbify(darkTheme.text.rgb),
  )
}

export function isFileNotSelectedInYazi(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    rgbify(darkTheme.base.rgb),
  )
}
