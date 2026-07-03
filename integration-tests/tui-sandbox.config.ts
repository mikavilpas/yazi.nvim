import { createDefaultConfig } from "@tui-sandbox/library/dist/src/server/config.js"
import type { TestServerConfig } from "@tui-sandbox/library/dist/src/server/index.js"

process.env.MISE_YES = "1"

export const config: TestServerConfig = createDefaultConfig(
  process.cwd(),
  process.env,
)
config.integrations.neovim.NVIM_APPNAMEs = [
  "nvim",
  "nvim_integrations",
  "nvim_no_package_manager",
]
config.formatter = { use: "oxfmt" }
