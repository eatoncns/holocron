describe('Exploring the site', function() {
  beforeEach(function() {
    cy.server();
    cy.route('https://swapi.co/**')
      .as('apiCall');
  });

  it('starts on search page', function() {
    cy.visit('/');
    cy.get('input.search')
      .type('lars');
    cy.get('button').click();
    cy.wait('@apiCall');
  });
});
