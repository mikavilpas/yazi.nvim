import type { RunExCommandOutput } from "@tui-sandbox/library/src/server/types"
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
