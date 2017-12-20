port module Main exposing (..)

import Model exposing (Position, ChromeState)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onClick)


-- PORTS FROM JAVASCRIPT


port onState : (ChromeState -> msg) -> Sub msg


port changeInfoWindowVisibility : Bool -> Cmd msg


init : ChromeState -> ( ChromeState, Cmd Msg )
init cs =
    ( { clicks = cs.clicks
      , infoWindowVisible = cs.infoWindowVisible
      , infoWindowPosition = Position 0 0
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | ToggleInfoWindowVisibility
    | NewState ChromeState


update : Msg -> ChromeState -> ( ChromeState, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleInfoWindowVisibility ->
            let
                visibility =
                    not model.infoWindowVisible
            in
                ( { model | infoWindowVisible = visibility }
                , changeInfoWindowVisibility visibility
                )

        NewState cs ->
            ( { model
                | clicks = cs.clicks
                , infoWindowVisible = cs.infoWindowVisible
                , infoWindowPosition = cs.infoWindowPosition
              }
            , Cmd.none
            )


view : ChromeState -> Html Msg
view model =
    Html.div
        [ A.style
            [ ( "width", "200px" )
            , ( "height", "100px" )
            ]
        ]
        [ Html.text ("[PopUp] clicks: " ++ toString model.clicks)
        , Html.fieldset []
            [ Html.label []
                [ Html.input
                    [ A.type_ "checkbox"
                    , onClick ToggleInfoWindowVisibility
                    , A.checked model.infoWindowVisible
                    ]
                    []
                , Html.text "Show InfoWindow"
                ]
            ]
        ]


subscriptions : ChromeState -> Sub Msg
subscriptions model =
    onState NewState


main : Program ChromeState ChromeState Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
