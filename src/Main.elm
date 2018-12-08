module Main exposing (main)

import Browser
import Page.Search as Search


main =
    Browser.element
        { init = Search.init
        , update = Search.update
        , view = Search.view
        , subscriptions = Search.subscriptions
        }
