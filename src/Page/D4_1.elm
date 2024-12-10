module Page.D4_1 exposing (config)

import Dict exposing (Dict)
import Helper.ParserExtra as Parser
import Helper.Render as Render
import Parser as Parser exposing (..)
import Types exposing (Config(..), Markdown)


config : Config
config =
    Config
        { parser =
            parserConfig.inputParser
                |> Parser.map (parserConfig.converter >> parserConfig.render)
        , defaultInput = defaultData
        , inputLabel = "Enter the input data"
        , identifier = "day-4-1"
        , title = "Day 4.1 - Ceres Search"
        , description = problem
        }


type Letter
    = X
    | M
    | A
    | S


parserConfig : Types.ParserConfig Grid Int
parserConfig =
    { inputParser = parseGrid
    , converter = numberOfXmas
    , render = Render.intWithMessage "Number of Xmas"
    }


defaultData =
    """MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""


problem : Markdown
problem =
    """## Day 4: Ceres Search

"Looks like the Chief's not here. Next!" One of The Historians pulls out a device and pushes the only button on it. After a brief flash, you recognize the interior of the Ceres monitoring station!

As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.

This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them. Here are a few ways XMAS might appear, where irrelevant characters have been replaced with .:

..X...
.SAMX.
.A..A.
XMAS.S
.X....

The actual word search will be full of letters instead. For example:

MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX

In this word search, XMAS occurs a total of 18 times; here's the same word search again, but where letters not involved in any XMAS have been replaced with .:

....XXMAS.
.SAMXMS...
...S..A...
..A.A.MS.X
XMASAMX.MM
X.....XA.A
S.S.S.S.SS
.A.A.A.A.A
..M.M.M.MM
.X.X.XMASX

Take a look at the little Elf's word search. How many times does XMAS appear?
"""


type alias Grid =
    Dict ( Int, Int ) Letter


parseGrid : Parser Grid
parseGrid =
    loop Dict.empty parseGridHelper


parseGridHelper : Grid -> Parser (Step Grid Grid)
parseGridHelper grid =
    oneOf
        [ succeed
            (\gridElement ->
                Done <| Dict.union gridElement grid
            )
            |= backtrackable parseGridChar
            |. end
        , succeed
            (\gridElement ->
                Loop <| Dict.union gridElement grid
            )
            |= parseGridChar
            |. chompWhile ((==) '\n')
        ]


parseGridChar : Parser Grid
parseGridChar =
    succeed
        (\position value ->
            Dict.singleton position value
        )
        |= getPosition
        |= getLetter


getLetter : Parser Letter
getLetter =
    chompIf Char.isAlpha
        |> getChompedString
        |> andThen
            (\c ->
                case c of
                    "X" ->
                        succeed X

                    "M" ->
                        succeed M

                    "A" ->
                        succeed A

                    "S" ->
                        succeed S

                    _ ->
                        Parser.problem <| "Expected X, M, A or S. Got " ++ c ++ "."
            )


numberOfXmas : Grid -> Int
numberOfXmas grid =
    -- let
    --     _ =
    --         Debug.log "parsed data" grid
    -- in
    Dict.foldl
        (\( x, y ) _ acc ->
            xmasSumHere grid ( x, y ) + acc
        )
        0
        grid


xmasSumHere : Grid -> ( Int, Int ) -> Int
xmasSumHere grid ( x, y ) =
    let
        xmasSum =
            \a b c d ->
                if a == X && b == M && c == A && d == S then
                    1

                else
                    0

        right =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x + 1, y ) grid)
                (Dict.get ( x + 2, y ) grid)
                (Dict.get ( x + 3, y ) grid)
                |> Maybe.withDefault 0

        left =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x - 1, y ) grid)
                (Dict.get ( x - 2, y ) grid)
                (Dict.get ( x - 3, y ) grid)
                |> Maybe.withDefault 0

        down =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x, y + 1 ) grid)
                (Dict.get ( x, y + 2 ) grid)
                (Dict.get ( x, y + 3 ) grid)
                |> Maybe.withDefault 0

        up =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x, y - 1 ) grid)
                (Dict.get ( x, y - 2 ) grid)
                (Dict.get ( x, y - 3 ) grid)
                |> Maybe.withDefault 0

        downRight =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x + 1, y + 1 ) grid)
                (Dict.get ( x + 2, y + 2 ) grid)
                (Dict.get ( x + 3, y + 3 ) grid)
                |> Maybe.withDefault 0

        upLeft =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x - 1, y - 1 ) grid)
                (Dict.get ( x - 2, y - 2 ) grid)
                (Dict.get ( x - 3, y - 3 ) grid)
                |> Maybe.withDefault 0

        downLeft =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x - 1, y + 1 ) grid)
                (Dict.get ( x - 2, y + 2 ) grid)
                (Dict.get ( x - 3, y + 3 ) grid)
                |> Maybe.withDefault 0

        upRight =
            Maybe.map4 xmasSum
                (Dict.get ( x, y ) grid)
                (Dict.get ( x + 1, y - 1 ) grid)
                (Dict.get ( x + 2, y - 2 ) grid)
                (Dict.get ( x + 3, y - 3 ) grid)
                |> Maybe.withDefault 0
    in
    right
        + left
        + down
        + up
        + downRight
        + upLeft
        + downLeft
        + upRight
