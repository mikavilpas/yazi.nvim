import type { TerminalApplication } from "./TerminalApplication"

/** A testable application that can be started, killed, and given input. For a
 * single instance of this interface, only a single instance can be running at
 * a time (1 to 1 mapping).
 */
export abstract class DisposableSingleApplication implements AsyncDisposable {
  protected application: TerminalApplication | undefined

  /**
   * Kill the current application and start a new one with the given arguments.
   */
  abstract startNextAndKillCurrent(startArgs: unknown): Promise<void>

  public async killCurrent(): Promise<void> {
    return this.application?.killAndWait()
  }

  public async write(input: string): Promise<void> {
    return this.application?.write(input)
  }

  public processId(): number | undefined {
    return this.application?.processId
  }

  async [Symbol.asyncDispose](): Promise<void> {
    if (this.processId() === undefined) {
      return
    }
    console.log(`Killing current application ${this.processId()}...`)
    await this.killCurrent()
  }
}
