export type StartAppMessageArguments = {
  command: string
  args: string[]
}

declare global {
  interface Window {
    startApp(args: StartAppMessageArguments): void
  }
}

export {}
