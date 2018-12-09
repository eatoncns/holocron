module Person exposing (Person, fetch)

import Http
import Json.Decode exposing (Decoder, field, int, map, map7, string)


type alias Person =
    { name : String
    , height : String
    , mass : String
    , hairColour : String
    , eyeColour : String
    , birthYear : String
    , gender : String
    }


fetch : Int -> (Result Http.Error Person -> msg) -> Cmd msg
fetch id msg =
    Http.get
        { url = "https://swapi.co/api/people/" ++ String.fromInt id ++ "/"
        , expect = Http.expectJson msg personDecoder
        }


personDecoder : Decoder Person
personDecoder =
    map7 Person
        nameDecoder
        heightDecoder
        massDecoder
        hairDecoder
        eyeDecoder
        birthYearDecoder
        genderDecoder


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
