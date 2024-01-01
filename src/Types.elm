module Types exposing (Config(..), Markdown, fromConfig)

import Html exposing (Html)
import Parser exposing (Parser)


type alias Markdown =
    String


type Config a b
    = Config
        { parser : Parser a
        , converter : a -> b
        , render : b -> Html ()
        , defaultInput : String
        , inputLabel : String
        , identifier : String
        , title : String
        , description : Markdown
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
        , description : Markdown
        }
fromConfig (Config config) =
    config
