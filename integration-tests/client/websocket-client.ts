import { flavors } from "@catppuccin/palette"
import { createTRPCClient, createWSClient, wsLink } from "@trpc/client"
import { FitAddon } from "@xterm/addon-fit"
import { Terminal } from "@xterm/xterm"
import "@xterm/xterm/css/xterm.css"
import type { StartNeovimArguments } from "../server/application/neovim/testEnvironmentTypes.ts"
import type { AppRouter } from "../server/server"
import "./style.css"
import { validateMouseEvent } from "./validateMouseEvent"

const wsClient = createWSClient({
  url: `ws://localhost:3000`,
  WebSocket: WebSocket,
})
const trpc = createTRPCClient<AppRouter>({
  links: [wsLink({ client: wsClient })],
})

const app = document.querySelector<HTMLDivElement>("#app")
if (!app) {
  throw new Error("No app element found")
}

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

trpc.neovim.onStdout.subscribe(undefined, {
  onData(data: string) {
    terminal.write(data)
  },
  onError(err: unknown) {
    console.error(`Error from Neovim`, err)
  },
})

/** Entrypoint for the test runner (cypress) */
window.startNeovim = async function (
  directory: string,
  startArgs?: StartNeovimArguments,
): Promise<void> {
  const terminalDimensions = { cols: terminal.cols, rows: terminal.rows }
  await trpc.neovim.start.mutate({
    directory,
    filename: startArgs?.filename ?? "initial-file.txt",
    startupScriptModifications: startArgs?.startupScriptModifications,
    terminalDimensions,
  })

  terminal.onData((data) => {
    // Send mouse clicks to the terminal application
    //
    // this gets called for mouse events. However, some mouse events seem to
    // confuse Neovim, so for now let's just send click events

    if (typeof data !== "string") {
      throw new Error(
        `unexpected onData message type: '${JSON.stringify(data)}'`,
      )
    }

    const mouseEvent = validateMouseEvent(data)
    if (mouseEvent) {
      void trpc.neovim.stdin.mutate(data).catch((error: unknown) => {
        console.error(`Error sending mouse event`, error)
      })
    }
  })
}

terminal.onKey((event) => {
  void trpc.neovim.stdin.mutate(event.key)
})
