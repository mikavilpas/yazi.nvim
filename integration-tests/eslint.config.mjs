import { FlatCompat } from "@eslint/eslintrc"
import js from "@eslint/js"
import noOnlyTests from "eslint-plugin-no-only-tests"
import path from "node:path"
import { fileURLToPath } from "node:url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
})

export default [
  {
    ignores: [
      "**/vite.config.js",
      "**/cypress.config.ts",
      "**/test-environment/",
      "eslint.config.mjs",
    ],
  },
  ...compat.extends(
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/strict-type-checked",
    "prettier",
  ),
  {
    plugins: {
      "no-only-tests": noOnlyTests,
    },

    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",

      parserOptions: {
        project: ["tsconfig.json"],
      },
    },

    rules: {
      "no-only-tests/no-only-tests": "error",
      "@typescript-eslint/require-await": "off",

      "no-restricted-syntax": [
        "error",
        {
          selector: "TSEnumDeclaration",
          message: "Don't declare enums",
        },
      ],

      "@typescript-eslint/restrict-template-expressions": [
        "error",
        {
          allowNumber: true,
          allowBoolean: true,
        },
      ],
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/no-import-type-side-effects": "error",
      "@typescript-eslint/explicit-module-boundary-types": ["warn"],
      "no-shadow": "off",
      "@typescript-eslint/no-shadow": ["error"],

      "lines-between-class-members": [
        "error",
        "always",
        {
          exceptAfterSingleLine: true,
        },
      ],

      "no-empty-function": [
        "error",
        {
          allow: ["constructors"],
        },
      ],

      "no-return-await": "off",
      "@typescript-eslint/return-await": "error",
      "no-useless-constructor": "off",

      "no-void": [
        "error",
        {
          allowAsStatement: true,
        },
      ],

      "@typescript-eslint/no-unused-vars": "off",
    },
  },
]
