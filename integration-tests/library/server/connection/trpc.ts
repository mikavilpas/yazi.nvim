import { initTRPC } from "@trpc/server"
import type { CreateWSSContextFnOptions } from "@trpc/server/adapters/ws"
import type { Socket } from "net"
import type { WebSocket } from "ws"

export type Connection = {
  clientId: WebSocket
  socket: Socket
}

export function createContext(opts: CreateWSSContextFnOptions): Connection {
  return { clientId: opts.res, socket: opts.req.socket }
}

type Context = Awaited<ReturnType<typeof createContext>>

export const trpc = initTRPC.context<Context>().create()
