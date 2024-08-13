import winston from "winston"

import type { ITerminalDimensions } from "@xterm/addon-fit"
import type { IPty } from "node-pty"
import pty from "node-pty"

// NOTE the size for the terminal was chosen so that it looks good in my
// cypress test preview
const defaultDimensions: ITerminalDimensions = { cols: 125, rows: 43 }

// NOTE separating stdout and stderr is not supported by node-pty
// https://github.com/microsoft/node-pty/issues/71
export class TerminalApplication {
  public readonly processId: number

  public readonly logger: winston.Logger

  private constructor(
    private readonly subProcess: IPty,
    public readonly onStdoutOrStderr: (data: string) => void,
  ) {
    this.processId = subProcess.pid

    this.logger = winston.createLogger({
      transports: [new winston.transports.Console()],
      defaultMeta: { pid: this.processId },
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.cli(),
      ),
    })

    this.logger.debug(`started`)

    subProcess.onData(this.onStdoutOrStderr)

    subProcess.onExit(({ exitCode, signal }) => {
      this.logger.debug(
        `Child process ${this.processId} exited with code ${String(exitCode)} and signal ${String(signal)}`,
      )
    })
  }

  /** @constructor Start a new terminal application. */
  public static start({
    onStdoutOrStderr,
    command,
    args,
    cwd,
    env,
    dimensions: givenDimensions,
  }: {
    onStdoutOrStderr: (data: string) => void
    command: string
    args: string[]
    cwd: string
    env?: NodeJS.ProcessEnv
    dimensions?: ITerminalDimensions
  }): TerminalApplication {
    const dimensions = givenDimensions ?? defaultDimensions

    console.log(`Starting '${command} ${args.join(" ")}' in cwd '${cwd}'`)
    const ptyProcess = pty.spawn(command, args, {
      name: "xterm-color",
      cwd,
      env,
      cols: dimensions.cols,
      rows: dimensions.rows,
    })

    const processId = ptyProcess.pid

    if (!processId) {
      throw new Error("Failed to spawn child process")
    }

    return new TerminalApplication(ptyProcess, onStdoutOrStderr)
  }

  /** Write to the terminal's stdin. */
  public write(data: string): void {
    this.subProcess.write(data)
  }

  public async killAndWait(): Promise<void> {
    console.log(`💣 Killing process ${this.processId}`)
    this.subProcess.kill()
    console.log(`💥 Killed process ${this.processId}`)
  }
}
