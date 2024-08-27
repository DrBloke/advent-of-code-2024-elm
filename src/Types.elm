module Types exposing
    ( Config(..)
    , Markdown
    , Page(..)
    , ParserConfig
    , defaultInput
    , fromConfig
    , identifier
    , routePage
    , title
    )

import Html exposing (Html)
import Parser exposing (Parser)


type Page
    = RockPaperScissors


type alias Markdown =
    String


type Config
    = Config
        { routePage : Page
        , parser : Parser (Html ())
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
        { routePage : Page
        , parser : Parser (Html ())
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


routePage : Config -> Page
routePage (Config config) =
    config.routePage


defaultInput : Config -> String
defaultInput (Config config) =
    config.defaultInput
