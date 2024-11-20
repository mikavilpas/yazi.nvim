/// <reference types="cypress" />

afterEach(() => {
  cy.task("showYaziLog")
  cy.task("removeYaziLog")
})
