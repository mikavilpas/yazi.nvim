import type { TerminalApplication } from "./TerminalApplication"

/** A testable application that can be started, killed, and given input. For a
 * single instance of this interface, only a single instance can be running at
 * a time (1 to 1 mapping).
 *
 * @typeParam T The type of context the tests should have, e.g. information
 * about a custom directory that the application is running in.
 *
 */
export abstract class DisposableSingleApplication<T>
  implements AsyncDisposable
{
  protected application: TerminalApplication | undefined

  /**
   * Kill the current application and start a new one with the given arguments.
   */
  abstract startNextAndKillCurrent(startArgs: unknown): Promise<T>

  public async killCurrent(): Promise<void> {
    await this.application?.killAndWait()
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
