describe('The person page', function() {
  beforeEach(function() {
    cy.server();
    cy.route('https://swapi.co/api/people/4/', 'fixture:darth_vader.json')
      .as('fetchVader');
    cy.visit('/person/4');
  });

  it('displays information about person', () => {
    cy.wait('@fetchVader');

    cy.contains('Darth Vader');
  });

});
