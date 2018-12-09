Star Wars Holocron
==================

A simple frontend for the [SWAPI (the Star Wars API)](https://swapi.co/).

The app can be used to search for characters in the Star Wars universe and find
out information about them.

A deployed version can be found
[here](https://dazzling-torvalds-23e478.netlify.com).

The app is written in [Elm](https://elm-lang.org/), styled with use of
[Furtive](http://furtive.co/), tested using
[cypress](https://www.cypress.io/) and bundled using
[parceljs](https://parceljs.org/).

## Development

##### Requirements

- [yarn](https://yarnpkg.com/en/docs/install)

##### Usage

```
yarn install            # install dependencies
yarn run dev            # run app locally (default localhost:1234)
yarn run cypress:open   # open cypress test GUI
yarn run cypress        # run cypress tests from command line
```

N.B. cypress tests are run against locally running app so will need yarn run
dev to have been run.

## Goals

Given the relatively limited time I am able to spend on this app I am
prioritising  what are in my opinion good practices over large feature set.

##### Error handling

The app should handle:

- Error statuses from api
- Slow load of api / slower internet connections

##### Testing strategy

I am from a predominantly backend background with a strong emphasis on TDD.
I wanted to experiment with Elm/cypress combination as it seems to tackle some of the
problems I see on other javascript based stacks.

In particular I have seen a lot of low value "change detector" implementation tests that
I think come from uncertainty about javascript features. Have we destructured
the input correctly? Are all the keys correct in the output object? I am hoping
the type system in Elm moves these kind of tests to the compiler, allowing
testing to be more about features of the app.

This fits nicely with the approach taken by cypress, writing tests
describing the interaction a user has rather than the underlying
implementation. With selenium/webdriver I have seen this fall down due to the
slow speed and flakiness of the tests but it looks like there are a number of features in
cypress to address this.

## Enhancements

Some considerations going forward if this were a production project:

- Accessibility
- [Localisation](https://developer.mozilla.org/en-US/docs/Mozilla/Localization/Web_Localizability/Creating_localizable_web_applications)
- Security concerns e.g. Content Security Policy, headers
