import * as assert from "assert"

describe("the healthcheck", () => {
  it("can run the :healthcheck for yazi.nvim", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim()

    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")

    cy.typeIntoTerminal(":checkhealth yazi{enter}")

    // the version of yazi.nvim itself should be shown
    cy.readFile("../.release-please-manifest.json").then(
      (yaziNvimManifest: unknown) => {
        assert.ok(typeof yaziNvimManifest === "object")
        assert.ok(yaziNvimManifest)
        assert.ok("." in yaziNvimManifest)
        assert.ok(typeof yaziNvimManifest["."] === "string")
        cy.contains(`Running yazi.nvim version ${yaziNvimManifest["."]}`)
      },
    )

    // the `yazi` and `ya` applications should be found successfully
    cy.contains(new RegExp("Found yazi version Yazi \\d+?.\\d+?.\\d+?"))
    cy.contains(new RegExp("Found ya version Ya \\d+?.\\d+?.\\d+?"))
    cy.contains("OK yazi")
  })
})
