import { TestServer } from "library/server"
import { trpc } from "library/server/connection/trpc"
import { neovimRouter } from "./neovim/neovimRouter"

/** Stack for managing resources that need to be disposed of when the server
 * shuts down */
await using autocleanup = new AsyncDisposableStack()
autocleanup.defer(() => {
  console.log("Closing any open test applications")
})
export { autocleanup }

const appRouter = trpc.router({ neovim: neovimRouter })
export type AppRouter = typeof appRouter

export const testServer = new TestServer(3000)
await testServer.startAndRun(appRouter)
