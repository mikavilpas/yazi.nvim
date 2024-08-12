import { exec } from "child_process"
import path from "path"
import { fileURLToPath } from "url"
import { createTempDir } from "./createTempDir"
import type { TestDirectory } from "./testEnvironmentTypes"

const __dirname = fileURLToPath(new URL(".", import.meta.url))

/** A neovim specific test directory */
export class NeovimTestDirectory implements AsyncDisposable {
  public constructor(public readonly directory: TestDirectory) {}

  public static async create(): Promise<NeovimTestDirectory> {
    const dir = await createTempDir()
    return new NeovimTestDirectory(dir)
  }

  public static testEnvironmentDir = path.join(
    path.join(__dirname, "..", "..", ".."),
    "test-environment/",
  )

  public async [Symbol.asyncDispose](): Promise<void> {
    exec(`rm -rf ${this.directory.rootPathAbsolute}`)
  }
}
