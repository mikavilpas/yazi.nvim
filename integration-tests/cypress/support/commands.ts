/// <reference types="cypress" />

/* eslint-disable @typescript-eslint/no-namespace */
// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
//
// declare global {
//   namespace Cypress {
//     interface Chainable {
//       login(email: string, password: string): Chainable<void>
//       drag(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       dismiss(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       visit(originalFn: CommandOriginalFn, url: string, options: Partial<VisitOptions>): Chainable<Element>
//     }
//   }
// }

import type {
  StartNeovimArguments,
  TestDirectory,
} from "server/neovim/environment/testEnvironmentTypes.ts"
import "../../client/__global.ts"

Cypress.Commands.add("startNeovim", (startArguments?: StartNeovimArguments) => {
  cy.window().then((win) => {
    return win.startNeovim(startArguments)
  })
})

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
      startNeovim(args?: StartNeovimArguments): Chainable<TestDirectory>
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
