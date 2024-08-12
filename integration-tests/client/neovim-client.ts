import { createTRPCClient, createWSClient, wsLink } from "@trpc/client"
import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/neovim/environment/testEnvironmentTypes.ts"
import type { AppRouter } from "server/server.ts"
import { startTerminal } from "../library/client/websocket-client.ts"
import "./__global.ts"
import "./style.css"

const app = document.querySelector<HTMLElement>("#app")
if (!app) {
  throw new Error("No app element found")
}

const wsClient = createWSClient({
  url: `ws://localhost:3000`,
  WebSocket: WebSocket,
})
const trpc = createTRPCClient<AppRouter>({
  links: [wsLink({ client: wsClient })],
})

const terminal = startTerminal(app, {
  onMouseEvent(data: string) {
    void trpc.neovim.stdin.mutate(data).catch((error: unknown) => {
      console.error(`Error sending mouse event`, error)
    })
  },
  onKeyPress(event) {
    void trpc.neovim.stdin.mutate(event.key)
  },
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

  return dir
}

trpc.neovim.onStdout.subscribe(undefined, {
  onData(data: string) {
    terminal.write(data)
  },
  onError(err: unknown) {
    console.error(`Error from Neovim`, err)
  },
})
