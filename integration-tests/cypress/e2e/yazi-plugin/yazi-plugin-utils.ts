import type { MyNeovimConfigModification } from "@tui-sandbox/library"
import type { RunLuaCodeOutput } from "@tui-sandbox/library/server"
import type { OverrideProperties } from "type-fest"
import * as z from "zod"

import type { MyTestDirectoryFile } from "../../../MyTestDirectory.ts"
import type {
  MyStartNeovimServerArguments,
  NeovimContext,
} from "../../support/tui-sandbox.js"

export const describeOnNightlyYazi = (title: string, fn: () => void): void => {
  const runner: (title: string, fn: () => void) => void =
    Cypress.expose("runNvimYaziPluginTests") === true ? describe : describe.skip
  runner(title, fn)
}

export const assertNvimYaziPluginIndicatorIsVisible =
  (): Cypress.Chainable<undefined> => cy.contains(String.fromCodePoint(0xf36f)) // nf-linux-neovim, ""

/**
 * Issue: yazi.nvim has both neovim keymaps as well as yazi keymaps (via
 * nvim.yazi) active. The end-to-end tests cannot tell which one activates
 * simply pressing the key because both are active for the same key.
 *
 * Solution: call this function to assert that the yazi.nvim keymap is not
 * active for the given key.
 */
export function assertKeymapNotOwnedByYaziNvim(
  nvim: NeovimContext,
  key: string,
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim
    .runLuaCode({
      luaCode: `
        local key = "${key}"
        local buf = vim.api.nvim_get_current_buf()
        local target = vim.api.nvim_replace_termcodes(key, true, true, true)
        local mapped = false
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, "t")) do
          if vim.api.nvim_replace_termcodes(map.lhs, true, true, true) == target then
            mapped = true
            break
          end
        end
        return { buftype = vim.bo[buf].buftype, mapped = mapped }
      `,
    })
    .then((result) => {
      const parsed = z
        .object({ buftype: z.string(), mapped: z.boolean() })
        .parse(result.value)

      // sanity check: we must actually be inspecting the yazi terminal buffer,
      // otherwise "no keymap found" would be meaningless
      expect(
        parsed.buftype,
        "expected to inspect the focused yazi terminal buffer",
      ).to.eql("terminal")

      expect(
        parsed.mapped,
        `yazi.nvim must not own a terminal-mode keymap for "${key}" - the key must be handled by the nvim.yazi plugin instead`,
      ).to.eql(false)
    })
}

const pluginStartupScriptModifications = [
  "add_yazi_context_assertions.lua",
  "yazi_config/enable_yazi_plugin_keymaps.lua",
] as const satisfies MyNeovimConfigModification<MyTestDirectoryFile>[]
type NonDefaultStartupModification = Exclude<
  MyNeovimConfigModification<MyTestDirectoryFile>,
  (typeof pluginStartupScriptModifications)[number]
>
export const openNeovimWithNvimYaziPlugin = (
  args?: OverrideProperties<
    MyStartNeovimServerArguments,
    { startupScriptModifications?: NonDefaultStartupModification[] }
  >,
): Cypress.Chainable<NeovimContext> =>
  cy.startNeovim({
    ...args,
    startupScriptModifications: [
      ...pluginStartupScriptModifications,
      ...(args?.startupScriptModifications ?? []),
    ],
    additionalEnvironmentVariables: {
      YAZI_LOG: "debug",
      ...args?.additionalEnvironmentVariables,
    },
  })
