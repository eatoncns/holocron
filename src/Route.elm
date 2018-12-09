module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s)


type Route
    = NotFound
    | Search
    | Person Int


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Search Parser.top
        , Parser.map Person (s "person" </> int)
        ]


fromUrl : Url -> Route
fromUrl url =
    case Parser.parse parser url of
        Just route ->
            route

        Nothing ->
            NotFound
