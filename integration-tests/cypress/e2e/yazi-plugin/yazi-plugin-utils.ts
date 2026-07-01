export const describeOnNightlyYazi = (title: string, fn: () => void): void => {
  const runner: (title: string, fn: () => void) => void =
    Cypress.expose("runNvimYaziPluginTests") === true ? describe : describe.skip
  runner(title, fn)
}

export const assertNvimYaziPluginIndicatorIsVisible =
  (): Cypress.Chainable<undefined> => cy.contains(String.fromCodePoint(0xf36f)) // nf-linux-neovim, ""
