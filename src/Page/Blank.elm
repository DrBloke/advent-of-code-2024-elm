module Page.Blank exposing (config)

import Helper.ParserExtra
import Html exposing (Html, div, text)
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , Trailing(..)
        , andThen
        , chompIf
        , chompUntil
        , chompWhile
        , end
        , float
        , getChompedString
        , getCol
        , int
        , keyword
        , loop
        , map
        , oneOf
        , problem
        , sequence
        , spaces
        , succeed
        , symbol
        , token
        )
import Types exposing (Config(..))


config : Config
config =
    Config
        { parser =
            parserConfig.inputParser
                |> Parser.map (parserConfig.converter >> render)
        , defaultInput = defaultData
        , inputLabel = "Enter the input data"
        , identifier = "blank"
        , title = "Blank"
        , description = "Enter description with markdown"
        }


parserConfig : Types.ParserConfig (List (List Int)) (List (List Int))
parserConfig =
    { inputParser = parseInput
    , converter = identity
    , render = render
    }


defaultData =
    """1 2 3
3 2 1
1 3 2
"""


parseInput : Parser (List (List Int))
parseInput =
    loop [] blockHelper
        |> andThen
            (\l ->
                if List.isEmpty l then
                    problem "Expecting lists of integers"

                else
                    succeed l
            )


blockHelper : List (List Int) -> Parser (Step (List (List Int)) (List (List Int)))
blockHelper lines =
    oneOf
        [ succeed (\line -> Loop (line :: lines))
            |. chompWhile (\c -> c == ' ' || c == '\t' || c == '\n')
            |= parseLine
            |. chompWhile (\c -> c == ' ' || c == '\t' || c == '\n')
        , succeed ()
            |. end
            |> map (\_ -> Done (List.reverse lines))
        ]


parseLine : Parser (List Int)
parseLine =
    loop [] lineHelper
        |> andThen
            (\l ->
                if List.isEmpty l then
                    problem "Expecting integers"

                else
                    succeed l
            )


lineHelper : List Int -> Parser (Step (List Int) (List Int))
lineHelper ints =
    oneOf
        [ succeed (\i -> Loop (i :: ints))
            |= int
            |. chompWhile (\c -> c == ' ' || c == '\t')
        , succeed <| Done (List.reverse ints)
        ]


render : List (List Int) -> Html ()
render =
    List.map
        (\ints ->
            let
                renderedInts =
                    List.map (\int -> String.fromInt int)
                        >> String.join " "
            in
            div []
                [ text <|
                    "The max of "
                        ++ renderedInts ints
                        ++ " is "
                        ++ (Maybe.map String.fromInt (List.maximum ints) |> Maybe.withDefault "")
                ]
        )
        >> Html.div []
