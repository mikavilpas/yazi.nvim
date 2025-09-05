import { createDefaultConfig } from "@tui-sandbox/library/dist/src/server/config.js"
import type { TestServerConfig } from "@tui-sandbox/library/dist/src/server/index.js"

export const config: TestServerConfig = createDefaultConfig(
  process.cwd(),
  process.env,
)
config.integrations.neovim.NVIM_APPNAMEs = ["nvim", "nvim_integrations"]
