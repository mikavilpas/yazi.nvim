import { flavors } from "@catppuccin/palette"
import { textIsVisibleWithBackgroundColor } from "@tui-sandbox/library/dist/src/client/cypress-assertions"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/src/server/types"
import type { NeovimContext } from "cypress/support/tui-sandbox"
import type { MyTestDirectoryFile } from "MyTestDirectory"
import { assertYaziIsReady } from "./yazi-utils"
const darkTheme = flavors.macchiato.colors
const lightTheme = flavors.latte.colors

export type CatppuccinRgb = (typeof flavors.macchiato.colors)["surface0"]["rgb"]
export function rgbify(color: CatppuccinRgb): string {
  return `rgb(${color.r.toString()}, ${color.g.toString()}, ${color.b.toString()})`
}

export const darkBackgroundColors = {
  normal: rgbify(darkTheme.base.rgb),
  // NOTE: this abstraction is super leaky. It assumes
  // config-modifications/modify_yazi_config_and_add_hovered_buffer_background.lua
  // or a similar modification is being used
  hovered: rgbify(darkTheme.surface2.rgb),
  hoveredInSameDirectory: rgbify(darkTheme.surface0.rgb),
}

export const lightBackgroundColors = {
  normal: rgbify(lightTheme.base.rgb),
}

// only works for the dark colorscheme for now
export function isHoveredInNeovim(text: string, color?: string): void {
  textIsVisibleWithBackgroundColor(text, color ?? darkBackgroundColors.hovered)
}

// only works for the dark colorscheme for now
export function isNotHoveredInNeovim(text: string): void {
  textIsVisibleWithBackgroundColor(text, darkBackgroundColors.normal)
}

export function isHoveredInNeovimWithSameDirectory(
  text: string,
  color?: string,
): void {
  textIsVisibleWithBackgroundColor(
    text,
    color ?? darkBackgroundColors.hoveredInSameDirectory,
  )
}

/** HACK in CI, there can be timing issues where the first hover event is
 * lost. Right now we work around this by selecting another file first, then
 * hovering the desired file.
 *
 * Requires the {add_command_to_reveal_a_file.lua} script to be loaded from
 * config-modifications.
 */
export function hoverFileAndVerifyItsHovered(
  nvim: NeovimContext,
  file: MyTestDirectoryFile,
): Cypress.Chainable<RunLuaCodeOutput> {
  assertYaziIsReady(nvim)
  // select another file (hacky) by going to the parent directory
  cy.typeIntoTerminal("h")

  const path = nvim.dir.rootPathAbsolute + "/" + file
  return nvim
    .runLuaCode({
      luaCode: `return Yazi_reveal_path("${path}")`,
    })
    .then(() => assertYaziIsHovering(nvim, file))
}

export function assertYaziIsHovering(
  nvim: NeovimContext,
  file: MyTestDirectoryFile,
): Cypress.Chainable<RunLuaCodeOutput> {
  const path = `${nvim.dir.rootPathAbsolute}/${file}`
  return nvim.waitForLuaCode({
    luaAssertion: `Yazi_is_hovering("${path}")`,
    timeoutMs: 5000,
  })
}
