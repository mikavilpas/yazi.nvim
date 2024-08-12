import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/neovim/environment/testEnvironmentTypes"

// This defines a way for the test runner to start Neovim
declare global {
  interface Window {
    startNeovim(startArguments?: StartNeovimArguments): Promise<TestDirectory>
  }
}

export {}
