import { existsSync } from "fs"
import { eventEmitter } from "library/server"
import { DisposableSingleApplication } from "library/server/utilities/DisposableSingleApplication"
import { TerminalApplication } from "library/server/utilities/TerminalApplication"
import path from "path"
import { NeovimTestDirectory } from "./environment/NeovimTestEnvironment"
import type {
  StartNeovimServerArguments,
  TestDirectory,
} from "./environment/testEnvironmentTypes"

export type StdinMessage = "stdin"
export type StdoutMessage = "stdout"
export type StartNeovimMessage = "startNeovim"
export type MouseEventMessage = "mouseEvent"

/*

Usage:
  nvim [options] [file ...]

Options:
  --cmd <cmd>           Execute <cmd> before any config
  +<cmd>, -c <cmd>      Execute <cmd> after config and first file
  -l <script> [args...] Execute Lua <script> (with optional args)
  -S <session>          Source <session> after loading the first file
  -s <scriptin>         Read Normal mode commands from <scriptin>
  -u <config>           Use this config file

  -d                    Diff mode
  -es, -Es              Silent (batch) mode
  -h, --help            Print this help message
  -i <shada>            Use this shada file
  -n                    No swap file, use memory only
  -o[N]                 Open N windows (default: one per file)
  -O[N]                 Open N vertical windows (default: one per file)
  -p[N]                 Open N tab pages (default: one per file)
  -R                    Read-only (view) mode
  -v, --version         Print version information
  -V[N][file]           Verbose [level][file]

  --                    Only file names after this
  --api-info            Write msgpack-encoded API metadata to stdout
  --clean               "Factory defaults" (skip user config and plugins, shada)
  --embed               Use stdin/stdout as a msgpack-rpc channel
  --headless            Don't start a user interface
  --listen <address>    Serve RPC API from this address
  --remote[-subcommand] Execute commands remotely on a server
  --server <address>    Specify RPC server to send commands to
  --startuptime <file>  Write startup timing messages to <file>

See ":help startup-options" for all options.

*/

export class NeovimApplication extends DisposableSingleApplication<TestDirectory> {
  private testDirectory: NeovimTestDirectory | undefined

  public async startNextAndKillCurrent(
    startArgs: StartNeovimServerArguments,
  ): Promise<TestDirectory> {
    await this[Symbol.asyncDispose]()

    this.testDirectory = await NeovimTestDirectory.create()

    const neovimArguments = ["-u", "test-setup.lua"]

    if (startArgs.startupScriptModifications) {
      for (const modification of startArgs.startupScriptModifications) {
        const file = path.join(
          this.testDirectory.directory.rootPathAbsolute,
          "config-modifications",
          modification,
        )
        if (!existsSync(file)) {
          throw new Error(
            `startupScriptModifications file does not exist: ${file}`,
          )
        }

        neovimArguments.push("-c", `lua dofile('${file}')`)
      }
    }

    if (typeof startArgs.filename === "string") {
      const file = path.join(
        this.testDirectory.directory.rootPathAbsolute,
        startArgs.filename,
      )
      neovimArguments.push(file)
    } else if (startArgs.filename.openInVerticalSplits.length > 0) {
      // `-O[N]` Open N vertical windows (default: one per file)
      neovimArguments.push("-O")

      for (const file of startArgs.filename.openInVerticalSplits) {
        const filePath = path.join(
          this.testDirectory.directory.rootPathAbsolute,
          file,
        )
        neovimArguments.push(filePath)
      }
    }

    this.application = TerminalApplication.start({
      command: "nvim",
      args: neovimArguments,

      cwd: NeovimTestDirectory.testEnvironmentDir,
      env: process.env,
      dimensions: startArgs.terminalDimensions,

      onStdoutOrStderr(data: string) {
        eventEmitter.emit("stdout" satisfies StdoutMessage, data)
      },
    })

    return this.testDirectory.directory
  }

  override async [Symbol.asyncDispose](): Promise<void> {
    await super.killCurrent()
    await this.testDirectory?.[Symbol.asyncDispose]()
  }
}
