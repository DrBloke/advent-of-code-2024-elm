module Route exposing (..)

import Maybe.Extra as Maybe
import Page.RockPaperScissors as RockPaperScissors
import Types exposing (Config)
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


pageToConfig : Page -> Config Int Int
pageToConfig page =
    case page of
        RockPaperScissors ->
            RockPaperScissors.config


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


pageToPath : Page -> String
pageToPath page =
    pageAndPath
        |> List.filter (\( page_, _ ) -> page_ == page)
        |> List.head
        |> Maybe.unwrap "" Tuple.second
