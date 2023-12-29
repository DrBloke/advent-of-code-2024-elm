module Types exposing (Config(..), fromConfig)

import Html exposing (Html)
import Parser exposing (Parser)


type Config a b
    = Config
        { parser : Parser a
        , converter : a -> b
        , render : b -> Html ()
        , defaultInput : String
        }


fromConfig :
    Config a b
    ->
        { parser : Parser a
        , converter : a -> b
        , render : b -> Html ()
        , defaultInput : String
        }
fromConfig (Config config) =
    config
