import type { RunLuaCodeOutput } from "@tui-sandbox/library/src/server/types"
import type { NeovimContext } from "cypress/support/tui-sandbox"

// The LSP server asks for confirmation. We have overridden the handler
// for the response with a fixed "immediately answer yes" response.
export function waitForRenameToHaveBeenConfirmed(
  nvim: NeovimContext,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.waitForLuaCode({
    luaAssertion: `assert(_G.YaziTestFileRenameConfirmations == 1)`,
  })
}
