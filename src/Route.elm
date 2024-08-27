module Route exposing (..)

import Maybe.Extra as Maybe
import Page.RockPaperScissors as RockPaperScissors
import Types exposing (Config, Page(..))
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, string, top)


type Route
    = Route Config
    | Index
    | NotFound String


allConfigs : List Types.Config
allConfigs =
    [ RockPaperScissors.config ]



-- pageToConfig : Page -> Config
-- pageToConfig page =
--     case page of
--         RockPaperScissors ->
--             RockPaperScissors.config


pathToRoute : String -> Route
pathToRoute path =
    allConfigs
        |> List.filter (\config -> Types.identifier config == path)
        |> List.head
        |> (\config -> Maybe.unwrap (NotFound path) Route config)


route : Parser (Route -> Route) Route
route =
    oneOf
        [ map Index top
        , map pathToRoute string
        ]


toRoute : String -> Route
toRoute string =
    Url.fromString string
        |> Maybe.unwrap
            Index
            (\url ->
                Maybe.withDefault Index (parse route url)
            )


pageToPath : Page -> String
pageToPath page =
    allConfigs
        |> List.filter (\config -> Types.routePage config == page)
        |> List.head
        |> (\config -> Maybe.unwrap "" Types.identifier config)
