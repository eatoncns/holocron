module People exposing (People, PersonPreview, search)

import Api
import Http
import Json.Decode exposing (Decoder, field, list, map, map2, string)


type alias People =
    List PersonPreview


type alias PersonPreview =
    { url : String
    , name : String
    }


search : String -> (Result Http.Error People -> msg) -> Cmd msg
search input msg =
    Api.get (Api.search input) msg searchResultDecoder


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
    map convertToLocalUrl (field "url" string)


convertToLocalUrl : String -> String
convertToLocalUrl url =
    "/person/" ++ extractId url



-- https://swapi.co/api/people/4/ -> 4


extractId : String -> String
extractId =
    Maybe.withDefault "" << lastElem << String.split "/" << String.dropRight 1


lastElem : List a -> Maybe a
lastElem =
    List.foldl (Just >> always) Nothing


nameDecoder : Decoder String
nameDecoder =
    field "name" string
