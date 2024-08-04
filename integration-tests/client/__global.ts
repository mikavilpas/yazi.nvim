import type { StartNeovimArguments } from "server/application/neovim/testEnvironmentTypes"

declare global {
  interface Window {
    startNeovim(
      directory: string,
      startArguments?: StartNeovimArguments,
    ): Promise<void>
  }
}
