import { observable } from "@trpc/server/observable"
import assert from "node:assert"
import {
  NeovimApplication,
  type StdoutMessage,
} from "server/application/neovim/NeovimApplication"
import { startNeovimServerArguments } from "server/application/neovim/environment/testEnvironmentTypes"
import { trpc } from "server/connection/trpc"
import { autocleanup, eventEmitter } from "server/server"
import z from "zod"
import { Lazy } from "../../utilities/Lazy"

// Right now only one test instance is supported at a time. In the future, we
// might want to support multiple test instances running in parallel
export const neovim = new Lazy(() => {
  const instance = new NeovimApplication()
  autocleanup.use(instance)
  return instance
})

export const neovimRouter = trpc.router({
  start: trpc.procedure
    .input(startNeovimServerArguments)
    .mutation(async (startArgs) => {
      const dir = await neovim.get().startNextAndKillCurrent(startArgs.input)

      assert(neovim.get().processId() !== undefined)
      console.log(`🚀 Started Neovim instance ${neovim.get().processId()}`)

      return dir
    }),

  onStdout: trpc.procedure.subscription(() => {
    return observable<string>((emit) => {
      const send = (data: unknown) => {
        assert(typeof data === "string")
        emit.next(data)
      }

      eventEmitter.on("stdout" satisfies StdoutMessage, send)

      return () => {
        eventEmitter.off("stdout" satisfies StdoutMessage, send)
      }
    })
  }),

  stdin: trpc.procedure.input(z.string()).mutation(async (options) => {
    await neovim.get().write(options.input)
  }),
})
