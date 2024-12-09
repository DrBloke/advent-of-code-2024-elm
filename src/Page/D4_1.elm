module Page.D4_1 exposing (config)

import Helper.ParserExtra as Parser
import Helper.Render as Render
import List.Extra as List
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


parserConfig : Types.ParserConfig (List String) Int
parserConfig =
    { inputParser = Parser.parseListOfStrings
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


numberOfXmas : List String -> Int
numberOfXmas horizontalForwards =
    let
        numOfCharsPerRow =
            (List.head horizontalForwards |> Maybe.withDefault "")
                |> String.length

        horizontalBackwards =
            List.map String.reverse horizontalForwards

        verticalUpwards =
            List.foldl
                (\row acc ->
                    List.zip (String.toList row) acc
                        |> List.map (\( head, rest ) -> head :: rest)
                )
                (List.repeat numOfCharsPerRow [])
                horizontalForwards
                |> List.map String.fromList

        verticalDownwards =
            List.map String.reverse verticalUpwards

        rowsAsChars =
            List.map String.toList horizontalForwards

        offSetRows =
            List.indexedFoldl
                (\index row acc ->
                    (List.repeat index "" ++ List.drop index (List.map String.fromChar row)) :: acc
                )
                []
                rowsAsChars

        diagonalTopToRight =
            List.foldl
                (\row acc ->
                    List.zip row acc
                        |> List.map (\( head, rest ) -> head :: rest)
                )
                (List.repeat numOfCharsPerRow [])
                offSetRows
    in
    List.length (Debug.log "verticalUpwards" diagonalTopToRight)
