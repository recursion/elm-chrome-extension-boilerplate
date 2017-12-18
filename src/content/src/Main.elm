port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Model exposing (Model, Position)
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
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())
    | NewState Int


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ Draggable.subscriptions DragMsg drag
        , onState NewState
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewState clicks ->
            ( { model | clicks = clicks }, Cmd.none )

        OnDragBy ( dx, dy ) ->
            ( { model | xy = Position (model.xy.x + dx) (model.xy.y + dy) }
            , Cmd.none
            )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig OnDragBy


view : Model -> Html Msg
view { xy } =
    let
        translate =
            "translate(" ++ (toString xy.x) ++ "px, " ++ (toString xy.y) ++ "px)"

        style =
            [ "transform" => translate
            , "padding" => "16px"
            , "background-color" => "lightgray"
            , "width" => "64px"
            , "cursor" => "move"
            , "border" => "1px solid black"
            , "position" => "fixed"
            , "bottom" => "3px"
            , "left" => "3px"
            , "z-index" => "50000"
            ]
    in
        Html.div
            ([ A.style style
             , Draggable.mouseTrigger () DragMsg
             ]
                ++ (Draggable.touchTriggers () DragMsg)
            )
            [ Html.text "Drag me" ]


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
