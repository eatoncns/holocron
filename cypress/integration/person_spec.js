describe('The person page', function() {
  beforeEach(function() {
    cy.server();
    cy.route('https://swapi.co/api/people/4/', 'fixture:darth_vader.json')
      .as('fetchVader');
    cy.route('https://swapi.co/api/starships/13/', 'fixture:tie_advanced.json')
      .as('fetchTieAdvanced');
    cy.visit('/person/4');
  });

  it('displays information about person', function() {
    cy.wait('@fetchVader');

    cy.contains('h1', 'Darth Vader').should('be.visible');
    cy.contains('.attribute', 'Height').children().last().should('have.text', '2.02 m');
    cy.contains('.attribute', 'Mass').children().last().should('have.text', '136 kg');
    cy.contains('.attribute', 'Hair colour').children().last().should('have.text', 'none');
    cy.contains('.attribute', 'Eye colour').children().last().should('have.text', 'yellow');
    cy.contains('.attribute', 'Birth year').children().last().should('have.text', '41.9BBY');
    cy.contains('.attribute', 'Gender').children().last().should('have.text', 'male');
  });

  it('displays collapsed starship card', function() {
    cy.contains('.expander', 'Starship').children().last().should('have.text', '+');
    cy.contains('.card', 'TIE Advanced').should('not.be.visible');
  });

  describe('when starship card is clicked', function() {
    beforeEach(function() {
      cy.contains('.expander', 'Starship').click();
      cy.wait('@fetchTieAdvanced');
    });
    it('expands to display primary starship information', function() {
      cy.contains('.expander', 'Starship').children().last().should('have.text', '-');
      cy.contains('.card', 'TIE Advanced').should('be.visible');
    });

    it('collapses card again when expander clicked', function() {
      cy.contains('.expander', 'Starship').click();
      cy.contains('.expander', 'Starship').children().last().should('have.text', '+');
      cy.contains('.card', 'TIE Advanced').should('not.be.visible');
    });
  });

  describe('when id does not correspond to person', function() {
    beforeEach(function() {
      cy.route({
        url: 'https://swapi.co/api/people/666/',
        method: 'GET',
        status: 404,
        response: {}
      }).as('apiNotFound');
      cy.visit('/person/666')
    });

    it('displays message', function() {
      cy.wait('@apiNotFound');

      cy.contains('I cannot recall that person').should('be.visible');
    });
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

      cy.contains('There is a disturbance in the force... error from SWAPI')
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

    it('displays loading message until loaded', function() {
      cy.contains('Searching my memory...').should('be.visible');

      cy.wait('@slowApi');

      cy.contains('Searching my memory...').should('not.be.visible');
    });
  });

  describe('when person has no starship', function() {
    beforeEach(function() {
      cy.fixture('darth_vader.json').then((vader) => {
        vader.starships = [];
        cy.route('https://swapi.co/api/people/22/', vader)
          .as('fetchNoStarshipVader');
      })
      cy.visit('/person/22');
      cy.wait('@fetchNoStarshipVader')
    });

    it('does not display the starship card', function() {
      cy.contains('.card').should('not.be.visible');
    });
  });

  describe('when starship fails to load',function() {
    beforeEach(function() {
      cy.fixture('darth_vader.json').then((vader) => {
        vader.starships = [
          "https://swapi.co/api/starships/14/"
        ];
        cy.route('https://swapi.co/api/people/23/', vader)
          .as('fetchStarshipFailVader');
      })
      cy.route({
        url: 'https://swapi.co/api/starships/14/',
        method: 'GET',
        status: 500,
        response: {}
      }).as('starshipApiError');
      cy.visit('/person/23');
      cy.wait('@fetchStarshipFailVader');
      cy.contains('.expander', 'Starship').click();
      cy.wait('@starshipApiError');
    });

    it('displays error message', function() {
      cy.contains('.card', 'There is a disturbance in the force... error from SWAPI')
        .should('be.visible');
    });
  });

  describe('when starship loading is slow', function() {
    beforeEach(function() {
      cy.fixture('darth_vader.json').then((vader) => {
        vader.starships = [
          "https://swapi.co/api/starships/15/"
        ];
        cy.route('https://swapi.co/api/people/24/', vader)
          .as('fetchStarshipSlowVader');
      })
      cy.route({
        url: 'https://swapi.co/api/starships/15/',
        delay: 2000,
        method: 'GET',
        status: 200,
        response: 'fixture:tie_advanced.json' }).as('slowLoadStarship');
      cy.visit('/person/24');
      cy.wait('@fetchStarshipSlowVader');
      cy.contains('.expander', 'Starship').click();
    });

    it('displays loading message', function() {
      cy.contains('.card', 'Searching my memory...').should('be.visible');

      cy.wait('@slowLoadStarship');

      cy.contains('.card', 'Searching my memory...').should('not.be.visible');
    });
  });
});
