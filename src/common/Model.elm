module Model exposing (..)

import Draggable


-- This is the model in common among all of our apps


type alias Model =
    { infoWindow : InfoWindow
    , portData : PortData
    }


type alias InfoWindow =
    { xy : Position
    , drag : Draggable.State ()
    , visible : Bool
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias PortData =
    { clicks : Int
    , infoWindowVisible : Bool
    }
