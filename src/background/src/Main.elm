port module Main exposing (..)

import Model exposing (Model, Position)
import Draggable


{- BUG? Runtime error if I don't import Json.Decode -}

import Json.Decode


-- PORTS FROM JAVASCRIPT


port clicked : (() -> msg) -> Sub msg



-- PORTS TO JAVASCRIPT


port broadcast : Int -> Cmd msg



-- MODEL


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { clicks = flags.clicks, xy = Position 32 32, drag = Draggable.init }
    , Cmd.none
    )


type Msg
    = NoOp
    | Click


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Click ->
            let
                nextModel =
                    { model | clicks = model.clicks + 1 }
            in
                ( nextModel, broadcast nextModel.clicks )


subscriptions : Model -> Sub Msg
subscriptions model =
    clicked (\_ -> Click)


type alias Flags =
    { clicks : Int
    }


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
