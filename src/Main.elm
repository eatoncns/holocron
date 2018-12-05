module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


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


type alias Model =
    { images : Images, content : String }


init : Images -> ( Model, Cmd Msg )
init images =
    ( { images = images, content = "" }, Cmd.none )



-- UPDATE


type Msg
    = Change String
    | Search


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change newContent ->
            ( { model | content = newContent }, Cmd.none )

        Search ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "py2" ]
        [ div [ class "txt--center" ]
            [ img [ class "jedi-logo", src model.images.logo ] []
            , p [ class "muted" ] [ text "Welcome to the holocron" ]
            ]
        , div [ class "measure my2" ]
            [ input
                [ class "search"
                , placeholder "What do you seek?"
                , value model.content
                , onInput Change
                ]
                []
            , button [ onClick Search ] [ text "Search" ]
            ]
        ]
