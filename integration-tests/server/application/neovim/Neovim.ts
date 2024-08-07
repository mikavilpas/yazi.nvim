import { existsSync } from "fs"
import path from "path"
import type { StartNeovimServerArguments } from "server/application/neovim/testEnvironmentTypes"
import { eventEmitter } from "server/server"
import { fileURLToPath } from "url"
import { DisposableSingleApplication } from "../../utilities/DisposableSingleApplication"
import { TerminalApplication } from "../../utilities/TerminalApplication"

export type StdinMessage = "stdin"
export type StdoutMessage = "stdout"
export type StartNeovimMessage = "startNeovim"
export type MouseEventMessage = "mouseEvent"

const __dirname = fileURLToPath(new URL(".", import.meta.url))
const testDirectory = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "test-environment/",
)

export class Neovim extends DisposableSingleApplication {
  public async startNextAndKillCurrent(
    startArgs: StartNeovimServerArguments,
  ): Promise<void> {
    await this.killCurrent()

    const args = ["-u", "test-setup.lua"]
    if (startArgs.startupScriptModifications) {
      for (const modification of startArgs.startupScriptModifications) {
        const file = path.join(
          testDirectory,
          "config-modifications",
          modification,
        )
        if (!existsSync(file)) {
          throw new Error(
            `startupScriptModifications file does not exist: ${file}`,
          )
        }

        args.push("-c", `lua dofile('${file}')`)
      }
    }

    if (typeof startArgs.filename === "string") {
      const file = path.join(startArgs.directory, startArgs.filename)
      args.push(file)
    } else if (startArgs.filename.openInVerticalSplits.length > 0) {
      // `-O[N]` Open N vertical windows (default: one per file)
      args.push("-O")

      for (const file of startArgs.filename.openInVerticalSplits) {
        const filePath = path.join(startArgs.directory, file)
        args.push(filePath)
      }
    }

    this.application = TerminalApplication.start({
      command: "nvim",
      args: args,

      cwd: testDirectory,
      env: process.env,
      dimensions: startArgs.terminalDimensions,

      onStdoutOrStderr(data: string) {
        eventEmitter.emit("stdout" satisfies StdoutMessage, data)
      },
    })
  }
}
