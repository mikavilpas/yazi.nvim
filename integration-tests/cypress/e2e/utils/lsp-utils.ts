import type { RunLuaCodeOutput } from "@tui-sandbox/library/server"
import type { NeovimContext } from "../../support/tui-sandbox"

// The LSP server asks for confirmation. We have overridden the handler
// for the response with a fixed "immediately answer yes" response.
export function waitForRenameToHaveBeenConfirmed(
  nvim: NeovimContext,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.waitForLuaCode({
    luaAssertion: `assert(_G.YaziTestFileRenameConfirmations == 1)`,
  })
}
