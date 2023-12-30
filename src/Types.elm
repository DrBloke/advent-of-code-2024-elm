module Types exposing (Config(..), fromConfig)

import Html exposing (Html)
import Parser exposing (Parser)


type Config a b
    = Config
        { parser : Parser a
        , converter : a -> b
        , render : b -> Html ()
        , defaultInput : String
        , inputLabel : String
        , identifier : String
        , title : String
        }


fromConfig :
    Config a b
    ->
        { parser : Parser a
        , converter : a -> b
        , render : b -> Html ()
        , defaultInput : String
        , inputLabel : String
        , identifier : String
        , title : String
        }
fromConfig (Config config) =
    config
