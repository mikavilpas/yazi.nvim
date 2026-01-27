import type { UserConfig } from "@commitlint/types"
import { RuleConfigSeverity } from "@commitlint/types"

// https://commitlint.js.org/
const config: UserConfig = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "body-max-line-length": [RuleConfigSeverity.Disabled],
  },
}

export default config
