import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/neovim/environment/testEnvironmentTypes"

// This defines a way for the test runner to start Neovim. We need a way for
// the test runner to do this because it doesn't have direct access to either
// the server or the client.
declare global {
  interface Window {
    startNeovim(startArguments?: StartNeovimArguments): Promise<TestDirectory>
  }
}

export {}
