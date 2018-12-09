module Page.Person exposing (Model, Msg, getContext, init, update, view)

import Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Message
import Person exposing (Person)
import Process
import Task exposing (Task)



-- MODEL


type Status
    = Loading
    | LoadingSlowly
    | Loaded Person
    | Error
    | NotFound


type alias Model =
    { context : Context, status : Status }


init : Context -> Int -> ( Model, Cmd Msg )
init context id =
    ( { context = context, status = Loading }
    , Cmd.batch
        [ Person.fetch id LoadedResult
        , Task.perform (\_ -> PassedSlowLoadingThreshold) slowLoadThreshold
        ]
    )


getContext : Model -> Context
getContext model =
    model.context



-- UPDATE


type Msg
    = PassedSlowLoadingThreshold
    | LoadedResult (Result Http.Error Person)


slowLoadThreshold : Task x ()
slowLoadThreshold =
    Process.sleep 500


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedResult result ->
            case result of
                Ok person ->
                    ( { model | status = Loaded person }, Cmd.none )

                Err (Http.BadStatus 400) ->
                    ( { model | status = NotFound }, Cmd.none )

                Err _ ->
                    ( { model | status = Error }, Cmd.none )

        PassedSlowLoadingThreshold ->
            case model.status of
                Loading ->
                    ( { model | status = LoadingSlowly }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Loading ->
            text ""

        Error ->
            div [ class "txt--center my2" ] [ text Message.error ]

        NotFound ->
            div [ class "txt--center my2" ] [ text Message.notFound ]

        LoadingSlowly ->
            div [ class "txt--center my2" ] [ text Message.slowLoad ]

        Loaded person ->
            div [ class "measure bg--off-white" ]
                [ h1 [] [ text person.name ]
                , div [ class "grd py1" ]
                    [ attributeRow
                        [ { label = "Height", value = formatHeight person.height }
                        , { label = "Mass", value = formatMass person.mass }
                        , { label = "Hair colour", value = person.hairColour }
                        ]
                    , attributeRow
                        [ { label = "Eye colour", value = person.eyeColour }
                        , { label = "Birth year", value = person.birthYear }
                        , { label = "Gender", value = person.gender }
                        ]
                    ]
                ]


formatHeight : String -> String
formatHeight =
    String.toFloat
        >> Maybe.withDefault 0
        >> (\x -> x / 100)
        >> String.fromFloat
        >> (\x -> x ++ " m")


formatMass : String -> String
formatMass massInKg =
    massInKg ++ " kg"


type alias Attribute =
    { label : String, value : String }


attributeRow : List Attribute -> Html msg
attributeRow attributes =
    div [ class "grd-row my2" ]
        (List.map attribute attributes)


attribute : Attribute -> Html msg
attribute a =
    div [ class "grd-row-col-2-6 attribute" ]
        [ div [ class "muted" ] [ text a.label ]
        , div [] [ text a.value ]
        ]
