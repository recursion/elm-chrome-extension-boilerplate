module Model exposing (..)

-- This is the model in common among all of our apps
-- TODO: change common Model to our ChromeState record


type alias Position =
    { x : Float
    , y : Float
    }



-- The state shared across chrome (and likely saved in chrome storage)


type alias ChromeState =
    { clicks : Int
    , infoWindowVisible : Bool
    , infoWindowPosition : Position
    }
