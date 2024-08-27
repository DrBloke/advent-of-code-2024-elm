module Types exposing
    ( Config(..)
    , Markdown
    , ParserConfig
    , defaultInput
    , description
    , fromConfig
    , identifier
    , inputLabel
    , parser
    , title
    )

import Html exposing (Html)
import Parser exposing (Parser)


type alias Markdown =
    String


type Config
    = Config
        { parser : Parser (Html ())
        , defaultInput : String
        , inputLabel : String
        , identifier : String
        , title : String
        , description : Markdown
        }


type alias ParserConfig a b =
    { inputParser : Parser a
    , converter : a -> b
    , render : b -> Html ()
    }


fromConfig :
    Config
    ->
        { parser : Parser (Html ())
        , defaultInput : String
        , inputLabel : String
        , identifier : String
        , title : String
        , description : Markdown
        }
fromConfig (Config config) =
    config


title : Config -> String
title (Config config) =
    config.title


identifier : Config -> String
identifier (Config config) =
    config.identifier


defaultInput : Config -> String
defaultInput (Config config) =
    config.defaultInput


parser : Config -> Parser (Html ())
parser (Config config) =
    config.parser


description : Config -> Markdown
description (Config config) =
    config.description


inputLabel : Config -> String
inputLabel (Config config) =
    config.inputLabel
