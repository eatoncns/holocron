Star Wars Holocron
==================

A simple frontend for the [SWAPI (the Star Wars API)](https://swapi.co/)

The app is written in [Elm](https://elm-lang.org/), tested using
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
```

## Goals

Given the relatively limited time I am able to spend on this app I am
prioritising  what are in my opinion good practices over large feature set.

##### Testing strategy

I am from a predominantly backend background with a strong emphasis on TDD.
Having recently worked on a number of react/redux frontend apps I have seen
a tendency to over unit test, in part because the frameworks are so interwoven
with the code being written.

I am interested in the approach taken by cypress, writing tests
describing the interaction a user has rather than the underlying
implementation. With selenium/webdriver I have seen this fall down due to the
slow speed and flakiness of the tests but there are a number of features in
cypress to address this.
