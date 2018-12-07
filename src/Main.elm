module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, list, map2, string)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias People =
    List Person


type alias Person =
    { url : String
    , name : String
    }


type alias Images =
    { logo : String }


type alias Model =
    { images : Images, searchText : String, people : Maybe People }


init : Images -> ( Model, Cmd Msg )
init images =
    ( { images = images, searchText = "", people = Nothing }, Cmd.none )



-- UPDATE


type Msg
    = SearchTextChange String
    | Search
    | SearchResult (Result Http.Error People)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchTextChange newSearchText ->
            ( { model | searchText = newSearchText }, Cmd.none )

        Search ->
            ( model, searchPerson model.searchText )

        SearchResult result ->
            case result of
                Ok people ->
                    ( { model | people = Just people }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "py2" ]
        [ header model
        , div [ class "search" ]
            [ searchBar model
            , searchResults model
            ]
        ]


header : Model -> Html Msg
header model =
    div [ class "txt--center" ]
        [ img [ class "jedi-logo", src model.images.logo ] []
        , p [ class "muted" ] [ text "Welcome to the holocron" ]
        ]


searchBar : Model -> Html Msg
searchBar model =
    div [ class "my2" ]
        [ div [ class "grd" ]
            [ div [ class "grd-row" ]
                [ div [ class "grd-row-col-5-6" ]
                    [ input
                        [ class "search"
                        , placeholder "What do you seek?"
                        , value model.searchText
                        , onInput SearchTextChange
                        ]
                        []
                    ]
                , div [ class "grd-row-col-1-6" ]
                    [ button [ class "btn btn--s btn--blue", onClick Search ] [ text "Search" ]
                    ]
                ]
            ]
        ]


searchResults : Model -> Html Msg
searchResults model =
    case model.people of
        Just people ->
            div [ class "my2" ]
                ([ p [ class "muted" ]
                    [ text (renderResultText people)
                    ]
                 ]
                    ++ List.map renderPersonResult people
                )

        Nothing ->
            text ""


renderResultText : People -> String
renderResultText people =
    "I know of "
        ++ (people |> List.length |> String.fromInt)
        ++ "..."


renderPersonResult : Person -> Html Msg
renderPersonResult person =
    div [ class "card txt--center" ]
        [ p [] [ text person.name ]
        ]



-- HTTP


searchPerson : String -> Cmd Msg
searchPerson input =
    Http.get
        { url = "https://swapi.co/api/people/?search=" ++ input
        , expect = Http.expectJson SearchResult searchResultDecoder
        }


searchResultDecoder : Decoder People
searchResultDecoder =
    field "results" peopleDecoder


peopleDecoder : Decoder People
peopleDecoder =
    list personDecoder


personDecoder : Decoder Person
personDecoder =
    map2 Person urlDecoder nameDecoder


urlDecoder : Decoder String
urlDecoder =
    field "url" string


nameDecoder : Decoder String
nameDecoder =
    field "name" string
