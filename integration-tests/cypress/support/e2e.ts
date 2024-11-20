// ***********************************************************
// This example support/e2e.ts is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import "./commands.ts"
import "./tui-sandbox.ts"

before(function () {
  // disable Cypress's default behavior of logging all XMLHttpRequests and
  // fetches to the Command Log
  // https://gist.github.com/simenbrekken/3d2248f9e50c1143bf9dbe02e67f5399?permalink_comment_id=4615046#gistcomment-4615046
  cy.intercept({ resourceType: /xhr|fetch/ }, { log: false })
})
