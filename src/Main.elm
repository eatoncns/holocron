module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, list, map, map2, string)


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


type Search
    = NotPerformedYet
    | Error
    | Result People


type alias Model =
    { images : Images, searchText : String, search : Search }


init : Images -> ( Model, Cmd Msg )
init images =
    ( { images = images, searchText = "", search = NotPerformedYet }, Cmd.none )



-- UPDATE


type Msg
    = SearchTextChange String
    | Search
    | SearchResult (Result Http.Error People)
    | SearchKeyDown Int


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (map tagger keyCode)


enterKey =
    13


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchTextChange newSearchText ->
            ( { model | searchText = newSearchText }, Cmd.none )

        SearchKeyDown key ->
            if key == enterKey then
                ( model, searchPerson model.searchText )

            else
                ( model, Cmd.none )

        Search ->
            ( model, searchPerson model.searchText )

        SearchResult result ->
            case result of
                Ok people ->
                    ( { model | search = Result people }, Cmd.none )

                Err _ ->
                    ( { model | search = Error }, Cmd.none )



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
                        , onKeyDown SearchKeyDown
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
    case model.search of
        Result people ->
            div [ class "my2" ]
                ([ p [ class "muted" ]
                    [ text (resultText people)
                    ]
                 ]
                    ++ List.map personResult people
                )

        Error ->
            div [ class "my2" ]
                [ p [ class "muted" ]
                    [ text errorText
                    ]
                ]

        NotPerformedYet ->
            text ""


resultText : People -> String
resultText people =
    "I know of "
        ++ (people |> List.length |> String.fromInt)
        ++ "..."


errorText : String
errorText =
    "There is a disturbance in the force... SWAPI is not responding"


personResult : Person -> Html Msg
personResult person =
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
