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
        , chompUntil
        , chompWhile
        , end
        , float
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


parserConfig : Types.ParserConfig (List Int) (List Int)
parserConfig =
    { inputParser = parseLine
    , converter = identity
    , render = render
    }


defaultData =
    """1 2 3
3 2 1
1 3 2
"""


parseLine : Parser (List Int)
parseLine =
    loop [] lineHelper


lineHelper : List Int -> Parser (Step (List Int) (List Int))
lineHelper ints =
    oneOf
        [ succeed (\int -> Loop (int :: ints))
            |= int
            |. chompWhile (\c -> c == ' ')
        , succeed ()
            |> map (\_ -> Done (List.reverse ints))
        , problem "what?"
        ]



-- parseLine : Parser (List Int)
-- parseLine =
--     -- sequence
--     --     { start = ""
--     --     , separator = "\n"
--     --     , end = ""
--     --     , spaces = spaces
--     --     , item = int
--     --     , trailing = Optional
--     --     }
--     succeed
-- render : List (List Int) -> Html ()
-- render =
--     List.map
--         (\ints ->
--             let
--                 renderedInts =
--                     List.map (\int -> String.fromInt int)
--                         >> String.join " "
--                         >> Html.text
--             in
--             div [] [ text <| "The max of " ++ renderedInts ints ++ "is " ++ max ints ]
--         )
--         >> Html.div []


render : List Int -> Html ()
render =
    List.map (\int -> String.fromInt int)
        >> String.join " "
        >> Html.text
