import { z } from "zod"

export type MultipleFiles = {
  openInVerticalSplits: IntegrationTestFile[]
}

export const multipleFiles = z.object({
  openInVerticalSplits: z.array(z.string()),
})

export const testDirectoryFile = z.enum([
  "initial-file.txt",
  "test-setup.lua",
  "modify_yazi_config_to_use_ya_as_event_reader.lua",
  "subdirectory/subdirectory-file.txt",
  "other-subdirectory/other-sub-file.txt",
  "routes/posts.$postId/route.tsx",
  "routes/posts.$postId/adjacent-file.txt",
  "routes/posts.$postId/should-be-excluded-file.txt",
])
export type TestDirectoryFile = z.infer<typeof testDirectoryFile>

export const integrationTestFile = z.union([z.literal("."), testDirectoryFile])
export type IntegrationTestFile = z.infer<typeof integrationTestFile>

export const startupScriptModification = z.enum([
  "modify_yazi_config_to_use_ya_as_event_reader.lua",
  "modify_yazi_config_and_add_hovered_buffer_background.lua",
  "use_light_neovim_colorscheme.lua",
  "modify_yazi_config_and_set_help_key.lua",
  "disable_a_keybinding.lua",
  "notify_hover_events.lua",
])
export type StartupScriptModification = z.infer<
  typeof startupScriptModification
>

/** The arguments given from the tests to send to the server */
export const startNeovimArguments = z.object({
  filename: z.union([integrationTestFile, multipleFiles]),
  startupScriptModifications: z.array(startupScriptModification).optional(),
})
export type StartNeovimArguments = z.infer<typeof startNeovimArguments>

/** The arguments given to the server */
export type StartNeovimServerArguments = z.infer<
  typeof startNeovimServerArguments
>

export const startNeovimServerArguments = z.intersection(
  z.object({
    directory: z.string(),
    terminalDimensions: z
      .object({
        cols: z.number(),
        rows: z.number(),
      })
      .optional(),
  }),
  startNeovimArguments,
)

export {}
