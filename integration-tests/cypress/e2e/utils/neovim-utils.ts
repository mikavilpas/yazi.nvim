import type {
  RunExCommandOutput,
  RunLuaCodeOutput,
} from "@tui-sandbox/library/dist/src/server/types"
import type { LiteralUnion } from "type-fest"
import * as z from "zod"
import type { MyTestDirectoryFile } from "../../../MyTestDirectory"
import type { NeovimContext } from "../../support/tui-sandbox"

export function assertNeovimCwd(
  nvim: NeovimContext,
  expectedCwd: LiteralUnion<MyTestDirectoryFile, string>,
): Cypress.Chainable<RunExCommandOutput> {
  return nvim.runExCommand({ command: "pwd" }).then((result) => {
    const pwd = z.string().parse(result.value)
    expect(pwd).to.eql(expectedCwd)
  })
}

export function setBufferLines(
  nvim: NeovimContext,
  lines: string[],
): Cypress.Chainable<RunLuaCodeOutput> {
  return nvim.runLuaCode({
    luaCode: `vim.api.nvim_buf_set_lines(0, 0, -1, false, {${lines.map((l) => `"${l.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`).join(", ")}})`,
  })
}
