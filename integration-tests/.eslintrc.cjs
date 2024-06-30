// @ts-check

/**
 * @type {import('eslint').Linter.Config}
 */
const config = {
  extends: [
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/strict-type-checked",
    "prettier",
  ],
  plugins: ["eslint-plugin-no-only-tests"],
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
    project: [
      "tsconfig.json",
      "./client/tsconfig.json",
      "./cypress/tsconfig.json",
    ],
  },
  ignorePatterns: ["vite.config.js", "cypress.config.ts"],
  rules: {
    "no-only-tests/no-only-tests": "error",
    "no-restricted-syntax": [
      "error",
      {
        // Disable all typescript enum usage.
        // Rationale: they have surprising issues, including:
        // - cyclic dependency issues
        // - enums without an explicit value depend on their initialization
        //   order (if someone changes the order of variants, it's a breaking
        //   change)
        //
        // Instead of enums:
        // - use a union type (e.g. `type MyType = 'a' | 'b'`)
        // - use an object with a constant (narrow) type (e.g. `const MyType = { a: 'a', b: 'b' } as const`)
        //
        // https://github.com/typescript-eslint/typescript-eslint/issues/561#issuecomment-496664453
        selector: "TSEnumDeclaration",
        message: "Don't declare enums",
      },
    ],

    // Automatically use `import type` for types (can simplify transpilation as type imports are never bundled in)
    "@typescript-eslint/consistent-type-imports": "error",
    "@typescript-eslint/no-import-type-side-effects": "error",

    // Require explicit return and argument types on exported functions' and classes' public class methods.
    // Explicit types for function return values and arguments makes it clear
    // to any calling code what is the module boundary's input and output.
    // Adding explicit type annotations for those types can help improve code
    // readability. It can also improve TypeScript type checking performance
    // on larger codebases.
    "@typescript-eslint/explicit-module-boundary-types": ["warn"],

    // Disable shadowing variables (prevents some bugs)
    "no-shadow": "off",
    "@typescript-eslint/no-shadow": ["error"],

    "lines-between-class-members": [
      "error",
      "always",
      {
        exceptAfterSingleLine: true,
      },
    ],
    // Functions cannot be empty, except for constructors (helps not forgetting to implement a function)
    "no-empty-function": [
      "error",
      {
        allow: ["constructors"],
      },
    ],

    // make sure no `catch` blocks are skipped because a returned promise is not awaited (this is a common mistake)
    "no-return-await": "off",
    "@typescript-eslint/return-await": "error",
    "no-useless-constructor": "off",
    "no-void": [
      "error",
      {
        allowAsStatement: true,
      },
    ],
    // use the typescript rule instead
    "@typescript-eslint/no-unused-vars": "off",
  },
}

module.exports = config
