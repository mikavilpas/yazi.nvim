// This defines a way for the test runner to start Neovim. We need a way for
// the test runner to do this because it doesn't have direct access to either
// the backend or the frontend

import type { TestDirectory } from "@tui-sandbox/library/src/server/types.ts"
import type { MyTestDirectory, testDirectoryFiles } from "../MyTestDirectory"
import type { MyStartNeovimServerArguments } from "./neovim-client.ts"

export type NeovimContext = {
  contents: MyTestDirectory
  /** provides easy access to all relative file paths from the root of the test
   * directory */
  files: (typeof testDirectoryFiles)["enum"]
  testDirectory: TestDirectory
}

declare global {
  interface Window {
    startNeovim(
      startArguments?: MyStartNeovimServerArguments,
    ): Promise<NeovimContext>
  }
}

export {}
