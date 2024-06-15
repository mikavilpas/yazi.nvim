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

import "../../client/startAppGlobalType"
import type { StartAppMessageArguments } from "../../client/startAppGlobalType"

export type StartNeovimArguments = {
  filename?: string
}

Cypress.Commands.add("startNeovim", (args?: StartNeovimArguments) => {
  cy.window().then((win) => {
    const startApp: StartAppMessageArguments = {
      command: "nvim",
      args: ["-u", "test-setup.lua", args?.filename ?? "initial-file.txt"],
    }
    win.startApp(startApp)
  })
})

Cypress.Commands.add("typeIntoTerminal", (text: string) => {
  // the syntax for keys is described here:
  // https://docs.cypress.io/api/commands/type
  cy.get("#app").type(text)
})

declare global {
  namespace Cypress {
    interface Chainable {
      startNeovim(args?: StartNeovimArguments): Chainable<void>
      typeIntoTerminal(text: string): Chainable<void>
    }
  }
}
