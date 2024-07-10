import type {
  StartNeovimArguments,
  TestDirectory,
} from "../../../client/testEnvironmentTypes"

export function startNeovimWithYa(
  args?: Partial<StartNeovimArguments>,
): Cypress.Chainable<TestDirectory> {
  return cy.startNeovim({
    ...args,
    startupScriptModifications: [
      "modify_yazi_config_to_use_ya_as_event_reader.lua",
    ],
  })
}
