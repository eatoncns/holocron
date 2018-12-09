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

});
