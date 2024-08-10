import { observable } from "@trpc/server/observable"
import assert from "node:assert"
import { Neovim, type StdoutMessage } from "server/application/neovim/Neovim"
import { startNeovimServerArguments } from "server/application/neovim/testEnvironmentTypes"
import { trpc } from "server/connection/trpc"
import { eventEmitter, stack } from "server/server"
import z from "zod"
import { Lazy } from "../../utilities/Lazy"

export const neovim = new Lazy(() => {
  const instance = new Neovim()
  stack.use(instance)
  return instance
})

export const neovimRouter = trpc.router({
  start: trpc.procedure
    .input(startNeovimServerArguments)
    .mutation(async (startArgs) => {
      await neovim.get().startNextAndKillCurrent(startArgs.input)

      assert(neovim.get().processId() !== undefined)
      console.log(`🚀 Started Neovim instance ${neovim.get().processId()}`)
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
