module Person exposing (Person, fetch)

import Api
import Http
import Json.Decode exposing (Decoder, field, int, list, map, map8, string)


type alias Person =
    { name : String
    , height : String
    , mass : String
    , hairColour : String
    , eyeColour : String
    , birthYear : String
    , gender : String
    , starshipId : Maybe Int
    }


fetch : Int -> (Result Http.Error Person -> msg) -> Cmd msg
fetch id msg =
    Api.get (Api.fetchPerson id) msg personDecoder


personDecoder : Decoder Person
personDecoder =
    map8 Person
        nameDecoder
        heightDecoder
        massDecoder
        hairDecoder
        eyeDecoder
        birthYearDecoder
        genderDecoder
        starshipIdDecoder


nameDecoder : Decoder String
nameDecoder =
    field "name" string


heightDecoder : Decoder String
heightDecoder =
    field "height" string


massDecoder : Decoder String
massDecoder =
    field "mass" string


hairDecoder : Decoder String
hairDecoder =
    field "hair_color" string


eyeDecoder : Decoder String
eyeDecoder =
    field "eye_color" string


birthYearDecoder : Decoder String
birthYearDecoder =
    field "birth_year" string


genderDecoder : Decoder String
genderDecoder =
    field "gender" string


starshipIdDecoder : Decoder (Maybe Int)
starshipIdDecoder =
    map extractFirstId (field "starships" (list string))


extractFirstId : List String -> Maybe Int
extractFirstId urls =
    case List.head urls of
        Nothing ->
            Nothing

        Just url ->
            extractId url


extractId : String -> Maybe Int
extractId =
    String.toInt << Maybe.withDefault "" << lastElem << String.split "/" << String.dropRight 1


lastElem : List a -> Maybe a
lastElem =
    List.foldl (Just >> always) Nothing
