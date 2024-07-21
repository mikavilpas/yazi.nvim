import { flavors } from "@catppuccin/palette"

const darkTheme = flavors.macchiato.colors
const lightTheme = flavors.latte.colors

function rgbify(color: (typeof darkTheme)["surface0"]["rgb"]) {
  return `rgb(${color.r.toString()}, ${color.g.toString()}, ${color.b.toString()})`
}

export const darkBackgroundColors = {
  normal: rgbify(darkTheme.base.rgb),
  // NOTE: this abstraction is super leaky. It assumes
  // config-modifications/modify_yazi_config_and_add_hovered_buffer_background.lua
  // is being used
  hovered: rgbify(darkTheme.surface1.rgb),
}

export const lightBackgroundColors = {
  normal: rgbify(lightTheme.base.rgb),
}

// only works for the dark colorscheme for now
export function isHovered(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    darkBackgroundColors.hovered,
  )
}

// only works for the dark colorscheme for now
export function isNotHovered(text: string): void {
  cy.contains(text).should(
    "have.css",
    "background-color",
    darkBackgroundColors.normal,
  )
}
