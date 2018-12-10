module Api exposing (fetchPerson, fetchStarship, get, search)

import Http
import Json.Decode exposing (Decoder)


type Endpoint
    = Search String
    | FetchPerson Int
    | FetchStarship Int


get : Endpoint -> (Result Http.Error a -> msg) -> Decoder a -> Cmd msg
get endpoint msg decoder =
    Http.get
        { url = endpointUrl endpoint
        , expect = Http.expectJson msg decoder
        }


endpointUrl : Endpoint -> String
endpointUrl endpoint =
    let
        path =
            case endpoint of
                Search input ->
                    "/people/?search=" ++ input

                FetchPerson id ->
                    "/people/" ++ String.fromInt id ++ "/"

                FetchStarship id ->
                    "/starships/" ++ String.fromInt id ++ "/"
    in
    "https://swapi.co/api" ++ path


search : String -> Endpoint
search input =
    Search input


fetchPerson : Int -> Endpoint
fetchPerson id =
    FetchPerson id


fetchStarship : Int -> Endpoint
fetchStarship id =
    FetchStarship id
