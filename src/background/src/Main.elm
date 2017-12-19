port module Main exposing (..)

import Model exposing (Model, Position, PortData)
import Draggable


{- BUG? Runtime error if I don't import Json.Decode -}
-- import Json.Decode
-- PORTS FROM JAVASCRIPT


port clicked : (() -> msg) -> Sub msg


port changeWindowVisibility : (() -> msg) -> Sub msg



-- PORTS TO JAVASCRIPT


port broadcast : PortData -> Cmd msg



-- Types


type Msg
    = NoOp
    | Click
    | ToggleInfoWindowVisibility


type alias Flags =
    { clicks : Int
    , infoWindowVisible : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { portData =
            { clicks = flags.clicks
            , infoWindowVisible = flags.infoWindowVisible
            }
      , infoWindow =
            { xy = Position 32 32
            , drag = Draggable.init
            , visible = flags.infoWindowVisible
            }
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
                infoWindow =
                    model.infoWindow

                nextInfoWindow =
                    { infoWindow | visible = not infoWindow.visible }

                pd =
                    model.portData

                nextPortData =
                    { pd | infoWindowVisible = not pd.infoWindowVisible }
            in
                ( { model
                    | infoWindow = nextInfoWindow
                    , portData = nextPortData
                  }
                , broadcast nextPortData
                )

        Click ->
            let
                portData =
                    model.portData

                nextPortData =
                    { portData | clicks = portData.clicks + 1 }

                nextModel =
                    { model | portData = nextPortData }
            in
                ( nextModel, broadcast nextModel.portData )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ clicked (\_ -> Click), changeWindowVisibility (\_ -> ToggleInfoWindowVisibility) ]


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
