module Page.Person exposing (Model, Msg, getContext, init, update, view)

import Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Person exposing (Person)



-- MODEL


type Status
    = Loading
    | Loaded Person
    | Error


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
                    ( { model | status = Error }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Loading ->
            text ""

        Error ->
            div [ class "txt--center my2" ] [ text errorMessage ]

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


errorMessage : String
errorMessage =
    "There is a disturbance in the force... SWAPI is not responding"
