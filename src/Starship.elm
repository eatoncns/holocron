module Starship exposing (Starship, fetch)

import Api
import Http
import Json.Decode exposing (Decoder, field, map, string)


type alias Starship =
    { name : String }


fetch : Int -> (Result Http.Error Starship -> msg) -> Cmd msg
fetch id msg =
    Api.get (Api.fetchStarship id) msg starshipDecoder


starshipDecoder : Decoder Starship
starshipDecoder =
    map Starship (field "name" string)
