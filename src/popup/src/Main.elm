port module Main exposing (..)

import Model exposing (Model, Position)
import Html exposing (Html)
import Html.Attributes
import Draggable


-- PORTS FROM JAVASCRIPT


port onState : (Int -> msg) -> Sub msg


init : ( Model, Cmd Msg )
init =
    ( { clicks = 0
      , xy = Position 0 0
      , drag = Draggable.init
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | NewState Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewState clicks ->
            ( { model | clicks = clicks }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.style
            [ ( "width", "200px" )
            , ( "height", "100px" )
            ]
        ]
        [ Html.text ("[PopUp] clicks: " ++ toString model.clicks)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    onState NewState


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
