module Route exposing (..)

import Maybe.Extra as Maybe
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, string, top)


type Route
    = Route Page
    | Index
    | NotFound String


type Page
    = RockPaperScissors


pageAndPath : List ( Page, String )
pageAndPath =
    [ ( RockPaperScissors, "rock-paper-scissors" ) ]


pathToRoute : String -> Route
pathToRoute path =
    pageAndPath
        |> List.filter (\( _, path_ ) -> path_ == path)
        |> List.head
        |> Maybe.unwrap (NotFound path) (Tuple.first >> Route)


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
