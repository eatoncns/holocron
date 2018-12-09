module Page.Search exposing (Model, Msg, getContext, init, update, view)

import Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import People exposing (People, PersonPreview)
import Process
import Task exposing (Task)



-- MODEL


type Search
    = NotPerformedYet
    | Loading
    | LoadingSlowly
    | Result People
    | Error


type alias Model =
    { context : Context, searchText : String, search : Search }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { context = context, searchText = "", search = NotPerformedYet }, Cmd.none )


getContext : Model -> Context
getContext model =
    model.context



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
    on "keydown" (D.map tagger keyCode)


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
                [ People.search model.searchText SearchResult
                , Task.perform (\_ -> PassedSlowLoadingThreshold) slowLoadThreshold
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
        [ img [ class "jedi-logo", src model.context.images.logo ] []
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
                ([ resultText (resultMessage people) ] ++ List.map personResult people)

        Error ->
            div [ class "my2" ] [ resultText errorMessage ]

        LoadingSlowly ->
            div [ class "my2" ] [ resultText slowLoadMessage ]

        Loading ->
            text ""

        NotPerformedYet ->
            text ""


resultText : String -> Html msg
resultText output =
    p [ class "muted" ] [ text output ]


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
    a [ href person.url ]
        [ div [ class "card txt--center" ]
            [ p [] [ text person.name ]
            ]
        ]
