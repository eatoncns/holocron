module Page.Person exposing (Model, Msg, getContext, init, update, view)

import Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Message
import Person exposing (Person)
import Process
import Starship exposing (Starship)
import Task exposing (Task)



-- MODEL


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Error
    | NotFound


type alias PersonStatus =
    Status Person


type StarshipStatus
    = NotRequested
    | Requested (Status Starship)


type StarshipCard
    = Expanded
    | Collapsed


type alias Model =
    { context : Context
    , personStatus : PersonStatus
    , starshipStatus : StarshipStatus
    , starshipCard : StarshipCard
    }


init : Context -> Int -> ( Model, Cmd Msg )
init context id =
    ( { context = context
      , personStatus = Loading
      , starshipStatus = NotRequested
      , starshipCard = Collapsed
      }
    , Cmd.batch
        [ Person.fetch id LoadedPersonResult
        , Task.perform (\_ -> PassedSlowLoadingThresholdPerson) slowLoadThreshold
        ]
    )


getContext : Model -> Context
getContext model =
    model.context



-- UPDATE


type Msg
    = PassedSlowLoadingThresholdPerson
    | LoadedPersonResult (Result Http.Error Person)
    | ToggleStarship
    | PassedSlowLoadingThresholdStarship
    | LoadedStarshipResult (Result Http.Error Starship)


slowLoadThreshold : Task x ()
slowLoadThreshold =
    Process.sleep 500


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedPersonResult result ->
            case result of
                Ok person ->
                    ( { model | personStatus = Loaded person }, Cmd.none )

                Err (Http.BadStatus 404) ->
                    ( { model | personStatus = NotFound }, Cmd.none )

                Err _ ->
                    ( { model | personStatus = Error }, Cmd.none )

        PassedSlowLoadingThresholdPerson ->
            case model.personStatus of
                Loading ->
                    ( { model | personStatus = LoadingSlowly }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ToggleStarship ->
            case model.personStatus of
                Loaded person ->
                    case ( model.starshipCard, model.starshipStatus ) of
                        ( Collapsed, NotRequested ) ->
                            ( { model | starshipStatus = Requested Loading, starshipCard = Expanded }
                            , loadStarship person.starshipId
                            )

                        ( Collapsed, _ ) ->
                            ( { model | starshipCard = Expanded }, Cmd.none )

                        ( Expanded, _ ) ->
                            ( { model | starshipCard = Collapsed }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PassedSlowLoadingThresholdStarship ->
            case model.starshipStatus of
                Requested Loading ->
                    ( { model | starshipStatus = Requested LoadingSlowly }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        LoadedStarshipResult result ->
            case result of
                Ok starship ->
                    ( { model | starshipStatus = Requested (Loaded starship) }, Cmd.none )

                Err _ ->
                    ( { model | starshipStatus = Requested Error }, Cmd.none )


loadStarship : Maybe Int -> Cmd Msg
loadStarship id =
    Cmd.batch
        [ Starship.fetch (Maybe.withDefault 0 id) LoadedStarshipResult
        , Task.perform (\_ -> PassedSlowLoadingThresholdStarship) slowLoadThreshold
        ]



-- VIEW


view : Model -> Html Msg
view model =
    case model.personStatus of
        Loading ->
            text ""

        Error ->
            div [ class "txt--center my2" ] [ text Message.error ]

        NotFound ->
            div [ class "txt--center my2" ] [ text Message.notFound ]

        LoadingSlowly ->
            div [ class "txt--center my2" ] [ text Message.slowLoad ]

        Loaded person ->
            div [ class "measure" ]
                [ personDetails person
                , starshipCard model person
                ]


personDetails : Person -> Html Msg
personDetails person =
    div [ class "bg--off-white" ]
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


attributeRow : List Attribute -> Html Msg
attributeRow attributes =
    div [ class "grd-row my2" ]
        (List.map attribute attributes)


attribute : Attribute -> Html Msg
attribute a =
    div [ class "grd-row-col-2-6 attribute" ]
        [ div [ class "muted" ] [ text a.label ]
        , div [] [ text a.value ]
        ]


starshipCard : Model -> Person -> Html Msg
starshipCard model person =
    case person.starshipId of
        Nothing ->
            text ""

        Just _ ->
            div
                [ class "card my2" ]
                ([ starshipCardHeader model ]
                    ++ starshipCardContent model
                )


starshipCardHeader : Model -> Html Msg
starshipCardHeader model =
    div
        [ class "expander"
        , onClick ToggleStarship
        ]
        [ text "Starship"
        , span [ class "bold" ] [ text (expansionIcon model.starshipCard) ]
        ]


expansionIcon : StarshipCard -> String
expansionIcon card =
    case card of
        Collapsed ->
            "+"

        Expanded ->
            "-"


starshipCardContent : Model -> List (Html Msg)
starshipCardContent model =
    case model.starshipCard of
        Collapsed ->
            []

        Expanded ->
            case model.starshipStatus of
                Requested (Loaded starship) ->
                    [ p [] [ text starship.name ]
                    , p [] [ text starship.model ]
                    , p [] [ text starship.class ]
                    ]

                Requested LoadingSlowly ->
                    [ div [ class "txt--center my2" ] [ text Message.slowLoad ] ]

                Requested Error ->
                    [ div [ class "txt--center my2" ] [ text Message.error ] ]

                Requested _ ->
                    []

                NotRequested ->
                    []
