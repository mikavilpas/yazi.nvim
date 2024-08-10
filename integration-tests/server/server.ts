import "core-js/proposals/async-explicit-resource-management"

import { applyWSSHandler } from "@trpc/server/adapters/ws"
import EventEmitter, { once } from "events"
import { WebSocketServer } from "ws"
import { neovimRouter } from "./application/neovim/neovimRouter"
import { createContext, trpc } from "./connection/trpc"

/** Stack for managing resources that need to be disposed of when the server
 * shuts down */
await using stack = new AsyncDisposableStack()
stack.defer(() => {
  console.log("Closing any open test applications")
})
export { stack }

console.log("🚀 Server starting")
export type AppRouter = typeof appRouter
const PORT = 3000

export const eventEmitter = new EventEmitter()

const appRouter = trpc.router({
  neovim: neovimRouter,
})

const wss = new WebSocketServer({ port: PORT })
const handler = applyWSSHandler({
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
console.log(`✅ WebSocket Server listening on ws://localhost:${PORT}`)

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
