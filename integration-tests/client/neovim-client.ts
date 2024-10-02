import { NeovimClient } from "@tui-sandbox/library/src/client"
import { z } from "zod"
import {
  MyTestDirectoryContentsSchema,
  testDirectoryFiles,
} from "../MyTestDirectory"
import type { NeovimContext } from "./__global"

const app = document.querySelector<HTMLElement>("#app")
if (!app) {
  throw new Error("No app element found")
}

const client = new NeovimClient(app)

/** The arguments given from the tests to send to the server. This one contains
 * the test environment's files in a type safe manner, whereas the server only
 * requires strings. */
export const myStartNeovimArguments = z.object({
  filename: z
    .union([
      testDirectoryFiles,
      z.object({
        openInVerticalSplits: z.array(testDirectoryFiles),
      }),
    ])
    .optional(),
  startupScriptModifications: z
    .array(
      z.enum(
        MyTestDirectoryContentsSchema.shape[
          "config-modifications"
        ].shape.contents.keyof().options,
      ),
    )
    .optional(),
})
export type MyStartNeovimServerArguments = z.infer<
  typeof myStartNeovimArguments
>

/** Entrypoint for the test runner (cypress) */
window.startNeovim = async function (
  startArgs?: MyStartNeovimServerArguments,
): Promise<NeovimContext> {
  const neovim = await client.startNeovim({
    filename: startArgs?.filename ?? "initial-file.txt",
    startupScriptModifications: startArgs?.startupScriptModifications,
  })

  return {
    contents: MyTestDirectoryContentsSchema.parse(neovim.contents),
    files: testDirectoryFiles.enum,
    testDirectory: neovim,
  }
}
