import { observable } from "@trpc/server/observable"
import assert from "node:assert"
import { Neovim, type StdoutMessage } from "server/application/neovim/Neovim"
import { startNeovimServerArguments } from "server/application/neovim/testEnvironmentTypes"
import { trpc } from "server/connection/trpc"
import { eventEmitter } from "server/server"
import z from "zod"

export const neovim = new Neovim()

export const neovimRouter = trpc.router({
  start: trpc.procedure
    .input(startNeovimServerArguments)
    .mutation(async (startArgs) => {
      await neovim.startNextAndKillCurrent(startArgs.input)

      assert(neovim.processId() !== undefined)
      console.log(`🚀 Started Neovim instance ${neovim.processId()}`)
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
    await neovim.write(options.input)
  }),
})
