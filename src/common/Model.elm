module Model exposing (..)

import Draggable


-- This is the model in common among all of our apps
-- TODO: change common Model to our ChromeState record
-- and move each components individual model to its own file


type alias InfoWindow =
    { xy : Position
    , drag : Draggable.State ()
    , visible : Bool
    }


type alias Position =
    { x : Float
    , y : Float
    }



-- The state shared across chrome (and likely saved in chrome storage)


type alias ChromeState =
    { clicks : Int
    , infoWindowVisible : Bool
    }
