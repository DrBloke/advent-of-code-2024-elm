module Page.D3_2 exposing (config)

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
        , identifier = "day-3-2"
        , title = "Day 3.2 - Mull it Over"
        , description = problem
        }


parserConfig : Types.ParserConfig (List ( Int, Int )) Int
parserConfig =
    { inputParser = parseMuls
    , converter = sumOfMultiples
    , render = Render.intWithMessage "Sum of multiples"
    }


defaultData =
    """xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"""


problem : Markdown
problem =
    """--- Day 3: Mull It Over ---

"Our computers are having issues, so I have no idea if we have any Chief Historians in stock! You're welcome to check the warehouse, though," says the mildly flustered shopkeeper at the North Pole Toboggan Rental Shop. The Historians head out to take a look.

The shopkeeper turns to you. "Any chance you can see why our computers are having issues again?"

The computer appears to be trying to run a program, but its memory (your puzzle input) is corrupted. All of the instructions have been jumbled up!

It seems like the goal of the program is just to multiply some numbers. It does that with instructions like mul(X,Y), where X and Y are each 1-3 digit numbers. For instance, mul(44,46) multiplies 44 by 46 to get a result of 2024. Similarly, mul(123,4) would multiply 123 by 4.

However, because the program's memory has been corrupted, there are also many invalid characters that should be ignored, even if they look like part of a mul instruction. Sequences like mul(4*, mul(6,9!, ?(12,34), or mul ( 2 , 4 ) do nothing.

For example, consider the following section of corrupted memory:

xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))

Only the four highlighted sections are real mul instructions. Adding up the result of each instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).

Scan the corrupted memory for uncorrupted mul instructions. What do you get if you add up all of the results of the multiplications?

"""


parseMuls : Parser (List ( Int, Int ))
parseMuls =
    loop [] parseLoop


parseLoop : List ( Int, Int ) -> Parser (Step (List ( Int, Int )) (List ( Int, Int )))
parseLoop pairs =
    oneOf
        [ end |> map (\_ -> Done (List.reverse pairs))
        , succeed
            (\maybeMul ->
                case maybeMul of
                    Just pair ->
                        Loop (List.reverse (pair :: pairs))

                    Nothing ->
                        Loop (List.reverse pairs)
            )
            |= oneOf
                [ parseMul |> map (\v -> Just v) |> backtrackable
                , dontDoBlock |> map (\_ -> Nothing)
                , chompIf (\_ -> True) |> map (\_ -> Nothing)
                ]
        ]


parseMul : Parser ( Int, Int )
parseMul =
    succeed (\a b -> ( a, b ))
        |. keyword "mul"
        |. symbol "("
        |= int
        |. symbol ","
        |= int
        |. symbol ")"



-- This shouldn't work. The string could end don't()skfjksmul(2,3)dfdf
-- Really we need dontBlock below, but it didn't seem relevant here.


dontDoBlock : Parser ()
dontDoBlock =
    multiComment "don't()" "do()" NotNestable



-- dontBlock : Parser ()
-- dontBlock =
--     succeed ()
--     |. keyword "don't()"
--     |. chompUntilEnd [Note this function doesn't exist]


sumOfMultiples : List ( Int, Int ) -> Int
sumOfMultiples xs =
    List.foldl (\( a, b ) acc -> a * b + acc) 0 xs
