import { createTRPCClient, createWSClient, wsLink } from "@trpc/client"
import { validateMouseEvent } from "../library/client/validateMouseEvent.ts"
import { startTerminal } from "../library/client/websocket-client.ts"
import type {
  StartNeovimArguments,
  TestDirectory,
} from "../library/server/application/neovim/environment/testEnvironmentTypes.ts"
import type { AppRouter } from "../library/server/server.ts"
import "./__global.ts"
import "./style.css"

const app = document.querySelector<HTMLElement>("#app")
if (!app) {
  throw new Error("No app element found")
}

const terminal = startTerminal(app)

const wsClient = createWSClient({
  url: `ws://localhost:3000`,
  WebSocket: WebSocket,
})
const trpc = createTRPCClient<AppRouter>({
  links: [wsLink({ client: wsClient })],
})

/** Entrypoint for the test runner (cypress) */
window.startNeovim = async function (
  startArgs?: StartNeovimArguments,
): Promise<TestDirectory> {
  const terminalDimensions = { cols: terminal.cols, rows: terminal.rows }
  const dir: TestDirectory = await trpc.neovim.start.mutate({
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

  return dir
}

terminal.onKey((event) => {
  void trpc.neovim.stdin.mutate(event.key)
})

trpc.neovim.onStdout.subscribe(undefined, {
  onData(data: string) {
    terminal.write(data)
  },
  onError(err: unknown) {
    console.error(`Error from Neovim`, err)
  },
})
