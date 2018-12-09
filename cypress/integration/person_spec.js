describe('The person page', function() {
  beforeEach(function() {
    cy.server();
    cy.route('https://swapi.co/api/people/4/', 'fixture:darth_vader.json')
      .as('fetchVader');
    cy.visit('/person/4');
  });

  it('displays information about person', () => {
    cy.wait('@fetchVader');

    cy.contains('h1', 'Darth Vader').should('be.visible');
    cy.contains('.attribute', 'Height').children().last().should('have.text', '2.02 m');
    cy.contains('.attribute', 'Mass').children().last().should('have.text', '136 kg');
    cy.contains('.attribute', 'Hair colour').children().last().should('have.text', 'none');
    cy.contains('.attribute', 'Eye colour').children().last().should('have.text', 'yellow');
    cy.contains('.attribute', 'Birth year').children().last().should('have.text', '41.9BBY');
    cy.contains('.attribute', 'Gender').children().last().should('have.text', 'male');
  });

  describe('when api is down', function() {
    beforeEach(function() {
      cy.route({
        url: 'https://swapi.co/api/people/5/',
        method: 'GET',
        status: 500,
        response: {}
      }).as('apiError');
      cy.visit('/person/5')
    });

    it('displays error message', function() {
      cy.wait('@apiError');

      cy.contains('There is a disturbance in the force... SWAPI is not responding')
        .should('be.visible');
    });
  });

  describe('when network is slow', function() {
    beforeEach(function() {
      cy.route({
        delay: 2000,
        url:'https://swapi.co/api/people/7/',
        method: 'GET',
        status: 200,
        response: 'fixture:darth_vader.json',
      }).as('slowApi');
      cy.visit('/person/7');
    });

    it('displays loading message until loaded', () => {
      cy.contains('Searching my memory...').should('be.visible');

      cy.wait('@slowApi');

      cy.contains('Searching my memory...').should('not.be.visible');
    });
  });

});
