import { flavors } from "@catppuccin/palette"
import { textIsVisibleWithBackgroundColor } from "@tui-sandbox/library"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/server"

import type { MyTestDirectoryFile } from "../../../MyTestDirectory.js"
import type { NeovimContext } from "../../support/tui-sandbox.js"
import { assertYaziIsReady } from "./yazi-utils.js"
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

export function isHoveredInNeovimWithSameDirectory(text: string, color?: string): void {
  textIsVisibleWithBackgroundColor(text, color ?? darkBackgroundColors.hoveredInSameDirectory)
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

/** Reveal a file in yazi and wait until our yazi confirms it is hovering it.
 *
 * In CI the `hover` DDS event yazi emits in response to a `reveal` can be lost,
 */
export function hoverFileAndVerifyItsHovered(
  nvim: NeovimContext,
  file: MyTestDirectoryFile,
): Cypress.Chainable<RunLuaCodeOutput> {
  assertYaziIsReady(nvim)
  const modulePath = `${nvim.dir.rootPathAbsolute}/config-modifications/add_command_to_reveal_a_file.lua`

  {
    // select another file (hacky) and wait for it to be hovered
    const dir = "config-modifications" satisfies MyTestDirectoryFile
    const path = nvim.dir.rootPathAbsolute + "/" + dir
    nvim.runLuaCode({
      luaCode: `return dofile("${modulePath}").reveal_path_and_wait_for_hover("${path}")`,
    })
  }

  const path = nvim.dir.rootPathAbsolute + "/" + file
  return nvim.runLuaCode({
    luaCode: `return dofile("${modulePath}").reveal_path_and_wait_for_hover("${path}")`,
  })
}
