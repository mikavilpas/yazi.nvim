/// <reference types="cypress" />

afterEach(function () {
  if (this.currentTest?.state === "failed") {
    cy.task("showYaziLog")
    cy.task("removeYaziLog")
  }
})
