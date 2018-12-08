module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf, s)


type Route
    = NotFound
    | Search


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Search Parser.top
        ]


fromUrl : Url -> Route
fromUrl url =
    case Parser.parse parser url of
        Just route ->
            route

        Nothing ->
            NotFound
