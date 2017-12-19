port module Main exposing (..)

import Model exposing (Model, Position, PortData)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Draggable


-- PORTS FROM JAVASCRIPT


port onState : (PortData -> msg) -> Sub msg


port changeInfoWindowVisibility : Bool -> Cmd msg


init : PortData -> ( Model, Cmd Msg )
init pd =
    ( { portData =
            { pd
                | clicks = pd.clicks
                , infoWindowVisible = pd.infoWindowVisible
            }
      , infoWindow =
            { xy = Position 0 0
            , drag = Draggable.init
            , visible = pd.infoWindowVisible
            }
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | ToggleInfoWindowVisibility
    | NewState PortData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleInfoWindowVisibility ->
            let
                infoWindow =
                    model.infoWindow

                visibility =
                    not infoWindow.visible

                nextInfoWindow =
                    { infoWindow | visible = visibility }
            in
                ( { model | infoWindow = nextInfoWindow }
                , changeInfoWindowVisibility visibility
                )

        NewState pd ->
            let
                portData =
                    model.portData

                nextPortData =
                    { portData
                        | clicks = pd.clicks
                        , infoWindowVisible = pd.infoWindowVisible
                    }

                infoWindow =
                    model.infoWindow

                nextInfoWindow =
                    { infoWindow | visible = pd.infoWindowVisible }
            in
                ( { model
                    | portData = nextPortData
                    , infoWindow = nextInfoWindow
                  }
                , Cmd.none
                )


view : Model -> Html Msg
view model =
    Html.div
        [ A.style
            [ ( "width", "200px" )
            , ( "height", "100px" )
            ]
        ]
        [ Html.text ("[PopUp] clicks: " ++ toString model.portData.clicks)
        , Html.fieldset []
            [ Html.label []
                [ Html.input
                    [ A.type_ "checkbox"
                    , onClick ToggleInfoWindowVisibility
                    , A.checked model.infoWindow.visible
                    ]
                    []
                , Html.text "Show InfoWindow"
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    onState NewState


main : Program PortData Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
