import type { UserConfig } from "@commitlint/types";
import { RuleConfigSeverity } from "@commitlint/types";

// https://commitlint.js.org/#/
const Configuration: UserConfig = {
  /*
   * Resolve and load @commitlint/config-conventional from node_modules.
   * Referenced packages must be installed
   */
  extends: ["@commitlint/config-conventional"],
  /*
   * Any rules defined here will override rules from @commitlint/config-conventional
   */
  rules: {
    "body-max-line-length": [RuleConfigSeverity.Warning, "always", 100],
    "header-max-length": [RuleConfigSeverity.Warning, "always", 100],
    "subject-case": [RuleConfigSeverity.Warning, "always", "sentence-case"],
  },
};

module.exports = Configuration;
