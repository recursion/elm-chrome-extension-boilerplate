port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Model exposing (Model, Position, PortData, InfoWindow)
import Draggable


-- PORTS FROM JAVASCRIPT


port onState : (PortData -> msg) -> Sub msg


init : PortData -> ( Model, Cmd Msg )
init portData =
    ( { portData =
            { clicks = portData.clicks
            , infoWindowVisible = portData.infoWindowVisible
            }
      , infoWindow =
            { xy = Position 0 0
            , drag = Draggable.init
            , visible = portData.infoWindowVisible
            }
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())
    | NewState PortData


subscriptions : Model -> Sub Msg
subscriptions { infoWindow } =
    Sub.batch
        [ Draggable.subscriptions DragMsg infoWindow.drag
        , onState NewState
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewState portDataIn ->
            let
                portData =
                    model.portData

                a =
                    Debug.log (toString portData) ()

                nextPortData =
                    { portData
                        | clicks = portDataIn.clicks
                        , infoWindowVisible = portDataIn.infoWindowVisible
                    }

                infoWindow =
                    model.infoWindow

                nextInfoWindow =
                    { infoWindow | visible = portDataIn.infoWindowVisible }
            in
                ( { model | portData = nextPortData, infoWindow = nextInfoWindow }, Cmd.none )

        OnDragBy ( dx, dy ) ->
            let
                infoWindow =
                    model.infoWindow

                nextInfoWindow =
                    { infoWindow | xy = Position (infoWindow.xy.x + dx) (infoWindow.xy.y + dy) }
            in
                ( { model | infoWindow = nextInfoWindow }
                , Cmd.none
                )

        DragMsg dragMsg ->
            let
                ( nextInfoWindow, infoWindowCmd ) =
                    Draggable.update dragConfig dragMsg model.infoWindow
            in
                ( { model | infoWindow = nextInfoWindow }, infoWindowCmd )


main : Program PortData Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.basicConfig OnDragBy


view : Model -> Html Msg
view model =
    if model.infoWindow.visible then
        infoWindow model.infoWindow
    else
        let
            style =
                [ "display" => "none" ]
        in
            Html.div [ A.style style ] []


infoWindow : InfoWindow -> Html Msg
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
