import { flavors } from "@catppuccin/palette"
import { FitAddon } from "@xterm/addon-fit"
import { Terminal } from "@xterm/xterm"
import "@xterm/xterm/css/xterm.css"

export function startTerminal(app: HTMLElement): Terminal {
  const terminal = new Terminal({
    cursorBlink: false,
    convertEol: true,
    fontSize: 13,
  })
  {
    const colors = flavors.macchiato.colors
    terminal.options.theme = {
      background: colors.base.hex,
      black: colors.crust.hex,
      brightBlack: colors.surface2.hex,
      blue: colors.blue.hex,
      brightBlue: colors.blue.hex,
      brightCyan: colors.sky.hex,
      brightRed: colors.maroon.hex,
      brightYellow: colors.yellow.hex,
      cursor: colors.text.hex,
      cyan: colors.sky.hex,
      foreground: colors.text.hex,
      green: colors.green.hex,
      magenta: colors.lavender.hex,
      red: colors.red.hex,
      white: colors.text.hex,
      yellow: colors.yellow.hex,
    }

    // The FitAddon makes the terminal fit the size of the container, the entire
    // page in this case
    const fitAddon = new FitAddon()
    terminal.loadAddon(fitAddon)
    terminal.open(app)
    fitAddon.fit()

    window.addEventListener("resize", () => {
      fitAddon.fit()
    })
  }

  return terminal
}
