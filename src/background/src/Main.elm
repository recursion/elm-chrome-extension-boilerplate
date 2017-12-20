port module Main exposing (..)

import Model exposing (Position, ChromeState)


{- BUG? Runtime error if I don't import Json.Decode -}
-- import Json.Decode
-- PORTS FROM JAVASCRIPT


port clicked : (() -> msg) -> Sub msg


port changeWindowVisibility : (() -> msg) -> Sub msg



-- PORTS TO JAVASCRIPT


port broadcast : ChromeState -> Cmd msg



-- Types


type Msg
    = NoOp
    | Click
    | ToggleInfoWindowVisibility


type alias Flags =
    { clicks : Int
    , infoWindowVisible : Bool
    }


type alias Model =
    { clicks : Int, infoWindowVisible : Bool }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { clicks = flags.clicks
      , infoWindowVisible = flags.infoWindowVisible
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleInfoWindowVisibility ->
            let
                nextModel =
                    { model
                        | infoWindowVisible = not model.infoWindowVisible
                    }
            in
                ( nextModel
                , broadcast nextModel
                )

        Click ->
            let
                nextModel =
                    { model | clicks = model.clicks + 1 }
            in
                ( nextModel, broadcast nextModel )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ clicked (\_ -> Click)
        , changeWindowVisibility (\_ -> ToggleInfoWindowVisibility)
        ]


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
