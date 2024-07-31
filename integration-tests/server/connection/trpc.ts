import { initTRPC } from "@trpc/server"
import type { CreateHTTPContextOptions } from "@trpc/server/adapters/standalone"
import type { CreateWSSContextFnOptions } from "@trpc/server/adapters/ws"

export function createContext(
  _opts: CreateHTTPContextOptions | CreateWSSContextFnOptions,
): object {
  return {}
}

type Context = Awaited<ReturnType<typeof createContext>>

export const trpc = initTRPC.context<Context>().create()
