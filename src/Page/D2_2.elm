module Page.D2_2 exposing (config)

import Accessibility.Role exposing (row)
import Helper.ParserExtra as Parser
import Helper.Render as Render
import Parser as Parser
import Types exposing (Config(..), Markdown)


config : Config
config =
    Config
        { parser =
            parserConfig.inputParser
                |> Parser.map (parserConfig.converter >> parserConfig.render)
        , defaultInput = defaultData
        , inputLabel = "Enter the input data"
        , identifier = "day-2-2"
        , title = "Day 2.2 - Red-Nosed Reports"
        , description = problem
        }


parserConfig : Types.ParserConfig (List (List Int)) Int
parserConfig =
    { inputParser = Parser.parseListOfListOfInt
    , converter = numberOfSafeInputs
    , render = Render.intWithMessage "Number of safe reports"
    }


defaultData =
    """7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"""


problem : Markdown
problem =
    """## Day 2: Red-Nosed Reports

Fortunately, the first location The Historians want to search isn't a long walk from the Chief Historian's office.

While the Red-Nosed Reindeer nuclear fusion/fission plant appears to contain no sign of the Chief Historian, the engineers there run up to you as soon as they see you. Apparently, they still talk about the time Rudolph was saved through molecular synthesis from a single electron.

They're quick to add that - since you're already here - they'd really appreciate your help analyzing some unusual data from the Red-Nosed reactor. You turn to check if The Historians are waiting for you, but they seem to have already divided into groups that are currently searching every corner of the facility. You offer to help with the unusual data.

The unusual data (your puzzle input) consists of many reports, one report per line. Each report is a list of numbers called levels that are separated by spaces. For example:

7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9

This example data contains six reports each containing five levels.

The engineers are trying to figure out which reports are safe. The Red-Nosed reactor safety systems can only tolerate levels that are either gradually increasing or gradually decreasing. So, a report only counts as safe if both of the following are true:

    The levels are either all increasing or all decreasing.
    Any two adjacent levels differ by at least one and at most three.

In the example above, the reports can be found safe or unsafe by checking those rules:

    7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
    1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
    9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
    1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
    8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
    1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.

So, in this example, 2 reports are safe.

Analyze the unusual data from the engineers. How many reports are safe?"""


numberOfSafeInputs : List (List Int) -> Int
numberOfSafeInputs xs =
    xs
        |> List.map
            (\row ->
                let
                    ascendingList : List Int
                    ascendingList =
                        if Maybe.withDefault 0 (List.head row) <= Maybe.withDefault 0 (List.head (List.reverse row)) then
                            row

                        else
                            List.reverse row

                    differencesValid : List Int -> Bool
                    differencesValid remaining =
                        case remaining of
                            y1 :: y2 :: [] ->
                                y2 - y1 >= 1 && y2 - y1 <= 3

                            y1 :: y2 :: ys ->
                                if y2 - y1 >= 1 && y2 - y1 <= 3 then
                                    differencesValid (y2 :: ys)

                                else
                                    False

                            _ ->
                                -- won't reach here unless you put list that is too short
                                False

                    oneItemRemoved : Int -> List Int -> List (List Int) -> List (List Int)
                    oneItemRemoved index collection acc =
                        if index == List.length collection + 1 then
                            acc

                        else
                            let
                                newList =
                                    List.take (index - 1) collection ++ List.reverse (List.reverse collection |> List.take (List.length collection - index))
                            in
                            oneItemRemoved (index + 1) collection (newList :: acc)
                in
                if differencesValid ascendingList then
                    True

                else
                    -- Lists with one item removed (Could use recursive function to stop when found a solution rather than constructing the whole list)
                    oneItemRemoved 1 ascendingList []
                        |> List.map differencesValid
                        |> List.filter identity
                        |> List.isEmpty
                        |> not
            )
        |> List.filter ((==) True)
        |> List.length