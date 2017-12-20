port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Model exposing (Position, ChromeState)
import Draggable


-- PORTS FROM JAVASCRIPT


port onState : (ChromeState -> msg) -> Sub msg


type alias Model =
    { xy : Position
    , drag : Draggable.State ()
    , visible : Bool
    }


type Msg
    = NoOp
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())
    | NewState ChromeState


init : ChromeState -> ( Model, Cmd Msg )
init chromeState =
    ( { xy = Position 0 0
      , drag = Draggable.init
      , visible = chromeState.infoWindowVisible
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , onState NewState
        ]


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig OnDragBy


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewState chromeStateIn ->
            ( { model
                | visible = chromeStateIn.infoWindowVisible
                , xy = chromeStateIn.infoWindowPosition
              }
            , Cmd.none
            )

        OnDragBy ( dx, dy ) ->
            let
                nextModel =
                    { model | xy = Position (model.xy.x + dx) (model.xy.y + dy) }
            in
                ( nextModel
                , Cmd.none
                )

        DragMsg dragMsg ->
            let
                ( nextModel, nextCmd ) =
                    Draggable.update dragConfig dragMsg model
            in
                ( nextModel, nextCmd )


main : Program ChromeState Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


view : Model -> Html Msg
view model =
    if model.visible then
        infoWindow model
    else
        noView


noView : Html Msg
noView =
    let
        style =
            [ "display" => "none" ]
    in
        Html.div [ A.style style ] []


infoWindow : Model -> Html Msg
infoWindow window =
    let
        translate =
            "translate(" ++ (toString window.xy.x) ++ "px, " ++ (toString window.xy.y) ++ "px)"

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
