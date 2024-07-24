module Types exposing
    ( Config(..)
    , Markdown
    , Page(..)
    , fromConfig
    , identifier
    , title
    )

import Html exposing (Html)
import Parser exposing (Parser)


type Page
    = RockPaperScissors


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


title : Config a b -> String
title (Config config) =
    config.title


identifier : Config a b -> String
identifier (Config config) =
    config.identifier
