module Page.NotFound exposing (view)

import Html exposing (..)


view : Html msg
view =
    div []
        [ h1 [] [ text "Page not found" ]
        , p [] [ text "These are not the droids you are looking for" ]
        ]
