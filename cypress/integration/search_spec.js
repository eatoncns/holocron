describe('The search page', () => {
  it('successfully loads', () => {
    cy.visit('/');
  });

  it('displays jedi logo', () => {
    cy.get('img.jedi-logo').should('be.visible');
  });

  it('allows user to search for people', () => {
    cy.get('input.search')
      .type('Darth')
      .should('have.value', 'Darth');

    cy.get('button').click();
  });
});
