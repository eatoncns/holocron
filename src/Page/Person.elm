module Page.Person exposing (Model, Msg, getContext, init, update, view)

import Context exposing (Context)
import Html exposing (..)
import Http
import Person exposing (Person)



-- MODEL


type Status
    = Loading
    | Loaded Person


type alias Model =
    { context : Context, status : Status }


init : Context -> Int -> ( Model, Cmd Msg )
init context id =
    ( { context = context, status = Loading }, Person.fetch id LoadedResult )


getContext : Model -> Context
getContext model =
    model.context



-- UPDATE


type Msg
    = LoadedResult (Result Http.Error Person)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedResult result ->
            case result of
                Ok person ->
                    ( { model | status = Loaded person }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Loading ->
            text ""

        Loaded person ->
            p [] [ text person.name ]
