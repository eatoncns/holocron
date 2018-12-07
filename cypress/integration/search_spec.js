describe('The search page', function() {
  beforeEach(function() {
    cy.server();
    cy.route('https://swapi.co/api/people/?search=Darth', 'fixture:darth_search.json')
      .as('searchDarth');
    cy.visit('/');
  });

  it('displays jedi logo', function() {
    cy.get('img.jedi-logo').should('be.visible');
  });

  it('displays welcome text', function() {
    cy.contains('Welcome to the holocron').should('be.visible');
  });

  it('allows user to search for people', function() {
    cy.get('input.search')
      .type('Darth')
      .should('have.value', 'Darth');

    cy.get('button').click();

    cy.wait('@searchDarth');

    cy.contains('Darth Vader').should('be.visible');
    cy.contains('Darth Maul').should('be.visible');
  });
});
