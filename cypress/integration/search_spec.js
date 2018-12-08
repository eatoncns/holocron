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

    cy.contains('I know of 2...').should('be.visible');
    cy.contains('Darth Vader').should('be.visible');
    cy.contains('Darth Maul').should('be.visible');
  });

  it('allows search to be triggered by pressing enter', () => {
    cy.get('input.search')
      .type('Darth{enter}')

    cy.wait('@searchDarth');
  });

  describe('when no people are found', function() {
    beforeEach(function() {
      cy.route('https://swapi.co/api/people/?search=Something', 'fixture:empty_search.json')
        .as('emptySearch');
    })

    it('displays message', function() {
      cy.get('input.search')
        .type('Something');

      cy.get('button').click();

      cy.wait('@emptySearch');

      cy.contains('I do not know anyone by that name');
    })
  });

  describe('when api is down', function() {
    beforeEach(function() {
      cy.route({
        url: 'https://swapi.co/api/people/?search=Blah',
        method: 'GET',
        status: 500,
        response: {}
      }).as('searchError');
    });

    it('displays error message', function() {
      cy.get('input.search')
        .type('Blah');

      cy.get('button').click();

      cy.wait('@searchError');

      cy.contains('There is a disturbance in the force... SWAPI is not responding');
    });
  });
});
