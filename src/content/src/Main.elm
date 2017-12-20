port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Model exposing (Position, ChromeState, InfoWindow)
import Draggable


-- PORTS FROM JAVASCRIPT


port onState : (ChromeState -> msg) -> Sub msg


type alias Model =
    { infoWindow : InfoWindow
    , chromeState : ChromeState
    }


type Msg
    = NoOp
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())
    | NewState ChromeState


init : ChromeState -> ( Model, Cmd Msg )
init chromeState =
    ( { chromeState =
            { clicks = chromeState.clicks
            , infoWindowVisible = chromeState.infoWindowVisible
            }
      , infoWindow =
            { xy = Position 0 0
            , drag = Draggable.init
            , visible = chromeState.infoWindowVisible
            }
      }
    , Cmd.none
    )


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

        NewState chromeStateIn ->
            let
                chromeState =
                    model.chromeState

                nextChromeState =
                    { chromeState
                        | clicks = chromeStateIn.clicks
                        , infoWindowVisible = chromeStateIn.infoWindowVisible
                    }

                infoWindow =
                    model.infoWindow

                nextInfoWindow =
                    { infoWindow | visible = chromeStateIn.infoWindowVisible }
            in
                ( { model | chromeState = nextChromeState, infoWindow = nextInfoWindow }, Cmd.none )

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


main : Program ChromeState Model Msg
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
