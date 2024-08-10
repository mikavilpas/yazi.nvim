import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/application/neovim/environment/testEnvironmentTypes"

declare global {
  interface Window {
    startNeovim(startArguments?: StartNeovimArguments): Promise<TestDirectory>
  }
}
