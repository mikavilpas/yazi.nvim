/* eslint-disable @typescript-eslint/no-namespace */
/// <reference types="cypress" />

import type { TestDirectory } from "@tui-sandbox/library/dist/src/server/types.ts"
import type { OverrideProperties } from "type-fest"
import type {
  MyTestDirectory,
  MyTestDirectoryFile,
} from "../../MyTestDirectory"

type MyStartNeovimServerArguments = {
  filename?:
    | MyTestDirectoryFile
    | { openInVerticalSplits: MyTestDirectoryFile[] }
  startupScriptModifications?: Array<
    keyof MyTestDirectory["config-modifications"]["contents"]
  >
}

export type NeovimContext = OverrideProperties<
  TestDirectory,
  {
    contents: MyTestDirectory
  }
>

declare global {
  interface Window {
    startNeovim(
      startArguments?: MyStartNeovimServerArguments,
    ): Promise<NeovimContext>
  }
}

Cypress.Commands.add(
  "startNeovim",
  (startArguments?: MyStartNeovimServerArguments) => {
    return cy.window().then((win) => win.startNeovim(startArguments))
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
