import { createTRPCClient, createWSClient, wsLink } from "@trpc/client"
import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/neovim/environment/testEnvironmentTypes.ts"
import type { AppRouter } from "server/server.ts"
import { getTabId, startTerminal } from "../library/client/websocket-client.ts"
import "./__global.ts"
import "./style.css"

const app = document.querySelector<HTMLElement>("#app")
if (!app) {
  throw new Error("No app element found")
}

const wsClient = createWSClient({ url: `ws://localhost:3000`, WebSocket })
const trpc = createTRPCClient<AppRouter>({
  links: [wsLink({ client: wsClient })],
})

const tabId = getTabId()

const terminal = startTerminal(app, {
  onMouseEvent(data: string) {
    void trpc.neovim.sendStdin
      .mutate({ tabId, data })
      .catch((error: unknown) => {
        console.error(`Error sending mouse event`, error)
      })
  },
  onKeyPress(event) {
    void trpc.neovim.sendStdin.mutate({ tabId, data: event.key })
  },
})

const ready = new Promise<void>((resolve) => {
  console.log("Subscribing to Neovim stdout")
  trpc.neovim.onStdout.subscribe(
    { client: tabId },
    {
      onStarted(_) {
        resolve()
      },
      onData(data: string) {
        terminal.write(data)
      },
      onError(err: unknown) {
        console.error(`Error from Neovim`, err)
      },
    },
  )
})

{
  /** Entrypoint for the test runner (cypress) */
  window.startNeovim = async function (
    startArgs?: StartNeovimArguments,
  ): Promise<TestDirectory> {
    await ready
    const terminalDimensions = { cols: terminal.cols, rows: terminal.rows }
    const neovim = await trpc.neovim.start.mutate({
      tabId,
      filename: startArgs?.filename ?? "initial-file.txt",
      startupScriptModifications: startArgs?.startupScriptModifications,
      terminalDimensions,
    })

    return neovim.dir
  }
}
