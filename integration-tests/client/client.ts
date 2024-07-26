import "@xterm/xterm/css/xterm.css"
import "./style.css"

import { flavors } from "@catppuccin/palette"
import { FitAddon } from "@xterm/addon-fit"
import { Terminal } from "@xterm/xterm"
import io from "socket.io-client"
import type {
  MouseEventMessage,
  StartNeovimMessage,
  StdinMessage,
  StdoutMessage,
} from "../server/server"

import type {
  StartNeovimArguments,
  StartNeovimServerArguments,
} from "./testEnvironmentTypes"
import { validateMouseEvent } from "./validateMouseEvent"

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

// The client application runs in the browser. The terminal application runs on
// the server. The client connects to the server using a WebSocket, constantly
// sending and receiving data.
//
// The terminal application's output is sent to the client, and the client's
// input is sent to the terminal application.
const socket = io("ws://localhost:3000/")

socket.on("connect_error", (err) => {
  console.error(`connect_error: `, err.message)
})

socket.on("disconnect", (reason) => {
  console.log("disconnected: ", reason)
})

window.startNeovim = async function startApp(
  directory: string,
  startArgs?: StartNeovimArguments,
) {
  await socket.emitWithAck(
    "startNeovim" satisfies StartNeovimMessage,
    {
      directory,
      filename: startArgs?.filename ?? "initial-file.txt",
      startupScriptModifications: startArgs?.startupScriptModifications,
    } satisfies StartNeovimServerArguments,
  )
}

socket.on(
  "stdout" satisfies StdoutMessage,
  (data: unknown, acknowledge: unknown) => {
    if (typeof data !== "string") {
      console.warn(`unexpected stdout message type: '${JSON.stringify(data)}'`)
      return
    }

    if (typeof acknowledge !== "function") {
      console.warn(
        `unexpected callback message type: '${JSON.stringify(acknowledge)}'`,
      )
      return
    }

    terminal.write(data)
    acknowledge()
  },
)

terminal.onKey((event) => {
  socket.emit("stdin" satisfies StdinMessage, event.key)
})

terminal.onData((data) => {
  // this gets called for mouse events. However, some mouse events seem to
  // confuse Neovim, so for now let's just send click events

  if (typeof data !== "string") {
    throw new Error(`unexpected onData message type: '${JSON.stringify(data)}'`)
  }

  const mouseEvent = validateMouseEvent(data)
  if (mouseEvent) {
    socket.emit("mouseEvent" satisfies MouseEventMessage, data)
  }
})
