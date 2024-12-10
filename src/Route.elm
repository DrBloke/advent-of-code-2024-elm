module Route exposing (..)

import Maybe.Extra as Maybe
import Page.D1_1 as D1_1
import Page.D1_2 as D1_2
import Page.D2_1 as D2_1
import Page.D2_2 as D2_2
import Page.D3_1 as D3_1
import Page.D3_2 as D3_2
import Page.D4_1 as D4_1
import Page.D4_2 as D4_2
import Types exposing (Config)
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, string, top)


type Route
    = Page Config
    | Index
    | NotFound String


allConfigs : List Types.Config
allConfigs =
    [ D1_1.config
    , D1_2.config
    , D2_1.config
    , D2_2.config
    , D3_1.config
    , D3_2.config
    , D4_1.config
    , D4_2.config
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
