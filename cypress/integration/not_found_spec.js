describe('Page not found', () => {
  it('displays message for unknown routes', () => {
    cy.visit('/some-unknown-route');
    cy.get('h1').contains('Page not found');
    cy.get('p').contains('These are not the droids you are looking for');
  });
});
