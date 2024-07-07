import type {
  StartNeovimArguments,
  TestDirectory,
} from "../../../client/testEnvironmentTypes"

/** NOTE: always uses the `modify_yazi_config_to_use_ya_as_event_reader.lua` as
 * that is implied by the name of the function.
 */
export function startNeovimWithYa(
  args?: Partial<StartNeovimArguments>,
): Cypress.Chainable<TestDirectory> {
  return cy.startNeovim({
    ...args,
    startupScriptModifications: [
      "modify_yazi_config_to_use_ya_as_event_reader.lua",
      ...(args?.startupScriptModifications ?? []),
    ],
  })
}
