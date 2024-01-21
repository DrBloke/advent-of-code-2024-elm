module Route exposing (..)

import Maybe.Extra as Maybe
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, string, top)


type Route
    = Route Page
    | Index
    | NotFound String


type Page
    = RockPaperScissors


pathToRoute : String -> Route
pathToRoute path =
    case path of
        "rock-paper-scissors" ->
            Route RockPaperScissors

        _ ->
            NotFound path


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
