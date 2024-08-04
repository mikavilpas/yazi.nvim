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

  contents: {
    ["initial-file.txt"]: FileEntry
    ["test-setup.lua"]: FileEntry
    ["file.txt"]: FileEntry
    ["modify_yazi_config_to_use_ya_as_event_reader.lua"]: FileEntry
    ["subdirectory/subdirectory-file.txt"]: FileEntry
    ["other-subdirectory/other-sub-file.txt"]: FileEntry
    ["routes/posts.$postId/route.tsx"]: FileEntry
    ["routes/posts.$postId/adjacent-file.txt"]: FileEntry
    ["routes/posts.$postId/should-be-excluded-file.txt"]: FileEntry
  }
}
