import packageConfig from "@mikavilpas/oxfmt-config"
import { defineConfig } from "oxfmt"

// oxlint-disable-next-line import/no-default-export
export default defineConfig({
  ...packageConfig,
  ignorePatterns: [
    "lazy-lock.json",
    "CHANGELOG.md",
    "release-please-config.json",
    ".release-please-manifest.json",
    "pnpm-lock.yaml",
    "integration-tests/dist",
  ],
})
