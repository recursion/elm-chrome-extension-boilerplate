module Model exposing (..)
import Draggable

-- This is the model in common among all of our apps


type alias Model =
    { clicks : Int
    , xy : Position
    , drag : Draggable.State ()
    }

type alias Position =
    { x : Float
    , y : Float
    }

