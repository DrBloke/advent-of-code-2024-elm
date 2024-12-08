module Route exposing (..)

import Maybe.Extra as Maybe
import Page.Blank as Blank
import Page.D1_1 as D1_1
import Page.RockPaperScissors as RockPaperScissors
import Types exposing (Config)
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, string, top)


type Route
    = Page Config
    | Index
    | NotFound String


allConfigs : List Types.Config
allConfigs =
    [ RockPaperScissors.config
    , Blank.config
    , D1_1.config
    ]


pathToRoute : String -> Route
pathToRoute path =
    allConfigs
        |> List.filter (\config -> Types.identifier config == path)
        |> List.head
        |> (\config -> Maybe.unwrap (NotFound path) Page config)


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
