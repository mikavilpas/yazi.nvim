import { flavors } from "@catppuccin/palette"

const darkTheme = flavors.macchiato.colors
const lightTheme = flavors.latte.colors

export function rgbify(color: (typeof darkTheme)["surface0"]["rgb"]): string {
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
  cy.contains(text).should(
    "have.css",
    "background-color",
    color ?? darkBackgroundColors.hovered,
  )
}

// only works for the dark colorscheme for now
export function isNotHoveredInNeovim(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    darkBackgroundColors.normal,
  )
}
