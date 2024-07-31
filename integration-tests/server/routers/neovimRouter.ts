import { observable } from "@trpc/server/observable"
import { startNeovimServerArguments } from "client/testEnvironmentTypes"
import assert from "node:assert"
import { trpc } from "server/connection/trpc"
import { application, eventEmitter } from "server/server"
import type { StdoutMessage } from "server/utilities/DisposableSingleApplication"
import z from "zod"

export const neovimRouter = trpc.router({
  start: trpc.procedure
    .input(startNeovimServerArguments)
    .mutation(async (startArgs) => {
      await application.startNextAndKillCurrent(startArgs.input)

      assert(application.processId() !== undefined)
      console.log(`🚀 Started Neovim instance ${application.processId()}`)
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
    await application.write(options.input)
  }),
})
