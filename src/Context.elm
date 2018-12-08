module Context exposing (Context, Images)

import Browser.Navigation as Nav


type alias Images =
    { logo : String }


type alias Context =
    { images : Images, key : Nav.Key }
