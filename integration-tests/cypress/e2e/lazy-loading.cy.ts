import { startNeovimWithYa } from "./using-ya-to-read-events/startNeovimWithYa"

describe("lazy loading yazi.nvim", () => {
  // The idea is that yazi.nvim exposes its public functions when you call
  // `require("yazi")`. It should load as little code up front as possible,
  // because some users don't use a package manager like lazy.nvim that
  // supports lazy loading modules by default.

  it("delays loading of many source code files", () => {
    // Not sure what would be a good way to test lazy loading. For now, just
    // load the plugin and see how many modules have been loaded.
    //
    // Maybe in the future, we can have a better way to do this.
    cy.visit("http://localhost:5173")
    startNeovimWithYa({
      startupScriptModifications: ["report_loaded_yazi_modules.lua"],
    })

    cy.typeIntoTerminal(":=CountYaziModules(){enter}")

    // NOTE: if this number changes in the future, it's ok. This test is just
    // to make sure that we don't accidentally load all modules up front due to
    // an unrelated change.
    cy.contains("Loaded 4 modules")
  })
})
