module People exposing (People, PersonPreview, search)

import Http
import Json.Decode exposing (Decoder, field, list, map2, string)


type alias People =
    List PersonPreview


type alias PersonPreview =
    { url : String
    , name : String
    }


search : String -> (Result Http.Error People -> msg) -> Cmd msg
search input msg =
    Http.get
        { url = "https://swapi.co/api/people/?search=" ++ input
        , expect = Http.expectJson msg searchResultDecoder
        }


searchResultDecoder : Decoder People
searchResultDecoder =
    field "results" peopleDecoder


peopleDecoder : Decoder People
peopleDecoder =
    list personDecoder


personDecoder : Decoder PersonPreview
personDecoder =
    map2 PersonPreview urlDecoder nameDecoder


urlDecoder : Decoder String
urlDecoder =
    field "url" string


nameDecoder : Decoder String
nameDecoder =
    field "name" string
