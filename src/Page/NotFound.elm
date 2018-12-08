module Page.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)


view : Html msg
view =
    div [ class "txt--center" ]
        [ h1 [] [ text "Page not found" ]
        , p [] [ text "These are not the droids you are looking for" ]
        ]
