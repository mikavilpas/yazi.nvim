import * as assert from "assert"
import { startNeovimWithYa } from "./using-ya-to-read-events/startNeovimWithYa"

describe("the healthcheck", () => {
  it("can run the :healthcheck for yazi.nvim", () => {
    cy.visit("http://localhost:5173")
    startNeovimWithYa()

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
    cy.contains("Found yazi version Yazi 0.2.5")
    cy.contains("Found ya version Ya 0.2.5")
    cy.contains("OK yazi")
  })
})
