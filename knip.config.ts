import config from "@mikavilpas/knip-config"

config.ignore = [
  "integration-tests/MyTestDirectory.ts",
  "integration-tests/tui-sandbox.config.ts",
  "integration-tests/test-environment/**",
]
config.ignoreDependencies = ["assert", "@commitlint/cli"]
config.ignoreBinaries = ["rumdl"]
config.ignoreExportsUsedInFile = true
config.workspaces = { ".": {} }

export default config
