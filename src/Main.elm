module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Context exposing (Context, Images)
import Html exposing (Html)
import Page.NotFound as NotFound
import Page.Person as Person
import Page.Search as Search
import Route exposing (Route)
import Url



-- MODEL


type Model
    = NotFound Context
    | SearchPage Search.Model
    | PersonPage Person.Model


init : Images -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init images url key =
    changeRouteTo (Route.fromUrl url) (NotFound (Context images key))



-- UPDATE


type Msg
    = Ignored
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | SearchMsg Search.Msg
    | PersonMsg Person.Msg


changeRouteTo : Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        context =
            getContext model
    in
    case route of
        Route.NotFound ->
            ( NotFound context, Cmd.none )

        Route.Search ->
            wrapPage SearchPage SearchMsg (Search.init context)

        Route.Person _ ->
            wrapPage PersonPage PersonMsg (Person.init context)


getContext : Model -> Context
getContext model =
    case model of
        NotFound context ->
            context

        SearchPage searchPage ->
            Search.getContext searchPage

        PersonPage personPage ->
            Person.getContext personPage


wrapPage : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
wrapPage toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( LinkClicked urlRequest, _ ) ->
            handleLinkClick urlRequest model

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( SearchMsg subMsg, SearchPage searchModel ) ->
            Search.update subMsg searchModel
                |> wrapPage SearchPage SearchMsg

        ( _, _ ) ->
            ( model, Cmd.none )


handleLinkClick : Browser.UrlRequest -> Model -> ( Model, Cmd Msg )
handleLinkClick urlRequest model =
    let
        context =
            getContext model
    in
    case urlRequest of
        Browser.Internal url ->
            ( model, Nav.pushUrl context.key (Url.toString url) )

        Browser.External href ->
            ( model, Nav.load href )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Star Wars Holocron"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html Msg
viewPage model =
    case model of
        NotFound _ ->
            Html.map (\_ -> Ignored) NotFound.view

        SearchPage searchModel ->
            Html.map SearchMsg (Search.view searchModel)

        PersonPage personModel ->
            Html.map (\_ -> Ignored) (Person.view personModel)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program Images Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
