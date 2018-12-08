module Main exposing (main)

import Browser
import Html exposing (Attribute, Html, button, div, img, input, p, text)
import Html.Attributes exposing (class, placeholder, src, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Http
import Json.Decode exposing (map)
import People exposing (People, PersonPreview)
import Process
import Task exposing (Task)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Images =
    { logo : String }


type Search
    = NotPerformedYet
    | Loading
    | LoadingSlowly
    | Result People
    | Error


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
    | PassedSlowLoadingThreshold


slowLoadThreshold : Task x ()
slowLoadThreshold =
    Process.sleep 500


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
                ( model, People.search model.searchText SearchResult )

            else
                ( model, Cmd.none )

        Search ->
            ( { model | search = Loading }
            , Cmd.batch
                [ People.search
                    model.searchText
                    SearchResult
                , Task.perform (\_ -> PassedSlowLoadingThreshold)
                    slowLoadThreshold
                ]
            )

        SearchResult result ->
            case result of
                Ok people ->
                    ( { model | search = Result people }, Cmd.none )

                Err _ ->
                    ( { model | search = Error }, Cmd.none )

        PassedSlowLoadingThreshold ->
            case model.search of
                Loading ->
                    ( { model | search = LoadingSlowly }, Cmd.none )

                _ ->
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
                        , placeholder "Who do you seek?"
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
                    [ text (resultMessage people)
                    ]
                 ]
                    ++ List.map personResult people
                )

        Error ->
            div [ class "my2" ]
                [ p [ class "muted" ]
                    [ text errorMessage
                    ]
                ]

        LoadingSlowly ->
            div [ class "my2" ]
                [ p [ class "muted" ]
                    [ text slowLoadMessage
                    ]
                ]

        Loading ->
            text ""

        NotPerformedYet ->
            text ""


resultMessage : People -> String
resultMessage people =
    case List.length people of
        0 ->
            "I do not know anyone by that name"

        _ ->
            "I know of "
                ++ (people |> List.length |> String.fromInt)
                ++ "..."


errorMessage : String
errorMessage =
    "There is a disturbance in the force... SWAPI is not responding"


slowLoadMessage : String
slowLoadMessage =
    "Searching my memory..."


personResult : PersonPreview -> Html Msg
personResult person =
    div [ class "card txt--center" ]
        [ p [] [ text person.name ]
        ]
