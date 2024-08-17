import { tabIdSchema } from "library/server/utilities/tabId"
import { z } from "zod"

export const testDirectoryFile = z.enum([
  "file.txt",
  "initial-file.txt",
  "file.txt",
  "test-setup.lua",
  "subdirectory/subdirectory-file.txt",
  "other-subdirectory/other-sub-file.txt",
  "dir with spaces/file1.txt",
  "dir with spaces/file2.txt",
  "routes/posts.$postId/route.tsx",
  "routes/posts.$postId/adjacent-file.txt",
  "routes/posts.$postId/should-be-excluded-file.txt",
])
export type TestDirectoryFile = z.infer<typeof testDirectoryFile>

export const integrationTestFile = z.union([z.literal("."), testDirectoryFile])
export type IntegrationTestFile = z.infer<typeof integrationTestFile>

export const startupScriptModification = z.enum([
  "modify_yazi_config_and_add_hovered_buffer_background.lua",
  "use_light_neovim_colorscheme.lua",
  "modify_yazi_config_and_set_help_key.lua",
  "disable_a_keybinding.lua",
  "notify_hover_events.lua",
  "modify_yazi_config_and_highlight_buffers_in_same_directory.lua",
  "modify_yazi_config_and_open_multiple_files.lua",
  "add_command_to_count_open_buffers.lua",
])
export type StartupScriptModification = z.infer<
  typeof startupScriptModification
>

export type MultipleFiles = {
  openInVerticalSplits: IntegrationTestFile[]
}

export const multipleFiles = z.object({
  openInVerticalSplits: z.array(integrationTestFile),
})

/** The arguments given from the tests to send to the server */
export const startNeovimArguments = z.object({
  filename: z.union([integrationTestFile, multipleFiles]).optional(),
  startupScriptModifications: z.array(startupScriptModification).optional(),
})
export type StartNeovimArguments = z.infer<typeof startNeovimArguments>

/** The arguments given to the server */
export type StartNeovimServerArguments = z.infer<
  typeof startNeovimServerArguments
>
export const startNeovimServerArguments = z.intersection(
  z.object({
    tabId: tabIdSchema,
    terminalDimensions: z
      .object({
        cols: z.number(),
        rows: z.number(),
      })
      .optional(),
  }),
  startNeovimArguments,
)

export type FileEntry = {
  /** The name of the file and its extension.
   * @example "file.txt"
   */
  name: string

  /** The name of the file without its extension.
   * @example "file"
   */
  stem: string

  /** The extension of the file.
   * @example ".txt"
   */
  extension: string
}

/** Describes the contents of the test directory, which is a blueprint for
 * files and directories. Tests can create a unique, safe environment for
 * interacting with the contents of such a directory.
 *
 * Having strong typing for the test directory contents ensures that tests can
 * be written with confidence that the files and directories they expect are
 * actually found. Otherwise the tests are brittle and can break easily.
 */
export type TestDirectory = {
  /** The path to the unique test directory (the root). */
  rootPathAbsolute: string

  /** The path to the unique test directory, relative to the root of the
   * test-environment directory. */
  rootPathRelativeToTestEnvironmentDir: string

  contents: Record<TestDirectoryFile, FileEntry>
}
