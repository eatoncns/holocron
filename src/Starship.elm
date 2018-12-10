module Starship exposing (Starship, fetch)

import Api
import Http
import Json.Decode exposing (Decoder, field, map3, string)


type alias Starship =
    { name : String, model : String, class : String }


fetch : Int -> (Result Http.Error Starship -> msg) -> Cmd msg
fetch id msg =
    Api.get (Api.fetchStarship id) msg starshipDecoder


starshipDecoder : Decoder Starship
starshipDecoder =
    map3 Starship
        (field "name" string)
        (field "model" string)
        (field "starship_class" string)
