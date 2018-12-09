module Person exposing (Person, fetch)

import Http
import Json.Decode exposing (Decoder, field, map, string)


type alias Person =
    { name : String }


fetch : Int -> (Result Http.Error Person -> msg) -> Cmd msg
fetch id msg =
    Http.get
        { url = "https://swapi.co/api/people/" ++ String.fromInt id ++ "/"
        , expect = Http.expectJson msg personDecoder
        }


personDecoder : Decoder Person
personDecoder =
    map Person nameDecoder


nameDecoder : Decoder String
nameDecoder =
    field "name" string
