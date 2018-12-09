module Page.Person exposing (Model, Msg, getContext, init, view)

import Context exposing (Context)
import Html exposing (..)



-- MODEL


type Msg
    = Dummy


type alias Model =
    { context : Context }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { context = context }, Cmd.none )


getContext : Model -> Context
getContext model =
    model.context



-- VIEW


view : Model -> Html Msg
view model =
    p [] [ text "Person" ]
