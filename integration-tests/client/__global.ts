import type {
  StartNeovimArguments,
  TestDirectory,
} from "../library/server/application/neovim/environment/testEnvironmentTypes.ts"

// This defines a way for the test runner to start Neovim
declare global {
  interface Window {
    startNeovim(startArguments?: StartNeovimArguments): Promise<TestDirectory>
  }
}

export {}
