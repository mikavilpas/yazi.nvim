import type { AnyRouter } from "@trpc/server"
import { applyWSSHandler } from "@trpc/server/adapters/ws"
import "core-js/proposals/async-explicit-resource-management"
import { once } from "events"
import { WebSocketServer } from "ws"
import { createContext } from "./connection/trpc"

export class TestServer {
  public constructor(private readonly port: number) {}

  // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-parameters
  public async startAndRun<TRouter extends AnyRouter>(
    appRouter: TRouter,
  ): Promise<void> {
    console.log("🚀 Server starting")

    const wss = new WebSocketServer({ port: this.port })
    const handler = applyWSSHandler<TRouter>({
      wss,
      router: appRouter,
      createContext,
      // Enable heartbeat messages to keep connection open (disabled by default)
      keepAlive: {
        enabled: true,
        // server ping message interval in milliseconds
        pingMs: 30_000,
        // connection is terminated if pong message is not received in this many milliseconds
        pongWaitMs: 5000,
      },
    })

    wss.on("connection", (socket) => {
      console.log(`➕➕ Connection (${wss.clients.size})`)
      socket.once("close", () => {
        console.log(`➖➖ Connection (${wss.clients.size})`)
      })
    })
    console.log(`✅ WebSocket Server listening on ws://localhost:${this.port}`)

    await Promise.race([once(process, "SIGTERM"), once(process, "SIGINT")])
    console.log("Shutting down...")
    handler.broadcastReconnectNotification()
    wss.close((error) => {
      if (error) {
        console.error("Error closing WebSocket server", error)
        process.exit(1)
      }
      console.log("WebSocket server closed")
      process.exit(0)
    })
  }
}
