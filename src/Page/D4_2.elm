module Page.D4_2 exposing (config)

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
        , identifier = "day-4-2"
        , title = "Day 4.2 - Ceres Search"
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
    """## Part Two ---

The Elf looks quizzically at you. Did you misunderstand the assignment?

Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:

M.S

.A.

M.S

Irrelevant characters have again been replaced with . in the above diagram. Within the X, each MAS can be written forwards or backwards.

Here's the same example from before, but this time all of the X-MASes have been kept instead:

.M.S......

..A..MSMS.

.M.S.MAA..

..A.ASMSM.

.M.S.M....

..........

S.S.S.S.S.

.A.A.A.A..

M.M.M.M.M.

..........

In this example, an X-MAS appears 9 times.

Flip the word search from the instructions back over to the word search side and try again. How many times does an X-MAS appear?"""


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
            \a b c d e ->
                if
                    a
                        == A
                        && ((b == M && c == S)
                                || (b == S && c == M)
                           )
                        && ((d == M && e == S)
                                || (d == S && e == M)
                           )
                then
                    1

                else
                    0
    in
    Maybe.map5 xmasSum
        (Dict.get ( x, y ) grid)
        (Dict.get ( x - 1, y - 1 ) grid)
        (Dict.get ( x + 1, y + 1 ) grid)
        (Dict.get ( x + 1, y - 1 ) grid)
        (Dict.get ( x - 1, y + 1 ) grid)
        |> Maybe.withDefault 0
