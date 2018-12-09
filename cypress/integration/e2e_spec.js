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

  it('moves to person details when search result selected', () => {
    cy.contains('div', 'Owen Lars').click();
    cy.wait('@apiCall');
    cy.url().should('include', '/person');
  });

  it('displays person details', () => {
    cy.contains('h1', 'Owen Lars').should('be.visible');
    cy.contains('.attribute', 'Height').children().last().should('not.to.be.empty');
    cy.contains('.attribute', 'Mass').children().last().should('not.to.be.empty');
    cy.contains('.attribute', 'Hair colour').children().last().should('not.to.be.empty');
    cy.contains('.attribute', 'Eye colour').children().last().should('not.to.be.empty');
    cy.contains('.attribute', 'Birth year').children().last().should('not.to.be.empty');
    cy.contains('.attribute', 'Gender').children().last().should('not.to.be.empty');
  });
});
