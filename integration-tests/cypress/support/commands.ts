/* eslint-disable @typescript-eslint/no-namespace */
/// <reference types="cypress" />

import "../../client/__global.ts"
import type { NeovimContext } from "../../client/__global.ts"
import type { MyStartNeovimServerArguments } from "../../client/neovim-client.ts"

Cypress.Commands.add(
  "startNeovim",
  (startArguments?: MyStartNeovimServerArguments) => {
    cy.window().then((win) => {
      return win.startNeovim(startArguments)
    })
  },
)

Cypress.Commands.add(
  "typeIntoTerminal",
  (text: string, options?: Partial<Cypress.TypeOptions>) => {
    // the syntax for keys is described here:
    // https://docs.cypress.io/api/commands/type
    cy.get("textarea").focus().type(text, options)
  },
)

declare global {
  namespace Cypress {
    interface Chainable {
      startNeovim(args?: MyStartNeovimServerArguments): Chainable<NeovimContext>
      typeIntoTerminal(
        text: string,
        options?: Partial<Cypress.TypeOptions>,
      ): Chainable<void>
    }
  }
}

afterEach(() => {
  cy.task("showYaziLog")
})

beforeEach(() => {
  cy.task("removeYaziLog")
})
