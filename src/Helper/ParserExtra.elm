module Helper.ParserExtra exposing
    ( TwoColumnsOfInts
    , deadEndsToString
    , parseListOfListOfInt
    , parseTwoColumnsOfInts
    )

import Parser exposing (..)


deadEndsToString : List Parser.DeadEnd -> String
deadEndsToString deadEnds =
    let
        deadEndToString : Parser.DeadEnd -> String
        deadEndToString deadEnd =
            let
                position : String
                position =
                    "row:" ++ String.fromInt deadEnd.row ++ " col:" ++ String.fromInt deadEnd.col ++ "\n"
            in
            case deadEnd.problem of
                Parser.Expecting str ->
                    "Expecting " ++ str ++ "at " ++ position

                Parser.ExpectingInt ->
                    "Expecting Int at " ++ position

                Parser.ExpectingHex ->
                    "Expecting Hex at " ++ position

                Parser.ExpectingOctal ->
                    "Expecting Octal at " ++ position

                Parser.ExpectingBinary ->
                    "Expecting Binary at " ++ position

                Parser.ExpectingFloat ->
                    "Expecting Float at " ++ position

                Parser.ExpectingNumber ->
                    "Expecting Number at " ++ position

                Parser.ExpectingVariable ->
                    "Expecting Variable at " ++ position

                Parser.ExpectingSymbol str ->
                    "Expecting Symbol " ++ str ++ " at " ++ position

                Parser.ExpectingKeyword str ->
                    "Expecting Keyword " ++ str ++ " at " ++ position

                Parser.ExpectingEnd ->
                    "Expecting End at " ++ position

                Parser.UnexpectedChar ->
                    "Unexpected Char at " ++ position

                Parser.Problem str ->
                    "ProblemString " ++ str ++ " at " ++ position

                Parser.BadRepeat ->
                    "BadRepeat at " ++ position
    in
    List.foldl (++) "" (List.map deadEndToString deadEnds)



-- Two columns of Int


type alias TwoColumnsOfInts =
    { col1 : List Int
    , col2 : List Int
    }


parseTwoColumnsOfInts : Parser TwoColumnsOfInts
parseTwoColumnsOfInts =
    loop { col1 = [], col2 = [] } parseLoop


parseLoop : TwoColumnsOfInts -> Parser (Step TwoColumnsOfInts TwoColumnsOfInts)
parseLoop { col1, col2 } =
    oneOf
        [ succeed (\newCols -> Done (TwoColumnsOfInts (col1 ++ newCols.col1) (col2 ++ newCols.col2)))
            |= backtrackable parseLine
            |. end
        , succeed (\newCols -> Loop (TwoColumnsOfInts (col1 ++ newCols.col1) (col2 ++ newCols.col2)))
            |= parseLine
            |. Parser.chompIf (\c -> c == '\n')
        ]


parseLine : Parser TwoColumnsOfInts
parseLine =
    succeed (\a b -> TwoColumnsOfInts [ a ] [ b ])
        |= int
        |. chompWhile (\c -> c == ' ' || c == '\t')
        |= int



-- List of List of Int


parseListOfListOfInt : Parser (List (List Int))
parseListOfListOfInt =
    loop [] blockHelper


blockHelper : List (List Int) -> Parser (Step (List (List Int)) (List (List Int)))
blockHelper lines =
    oneOf
        [ succeed (\line -> Done (List.reverse (line :: lines)))
            |= backtrackable parseLineOfInts
            |. end
        , succeed (\line -> Loop (line :: lines))
            |= parseLineOfInts
        ]


parseLineOfInts : Parser (List Int)
parseLineOfInts =
    loop [] lineHelper


lineHelper : List Int -> Parser (Step (List Int) (List Int))
lineHelper ints =
    -- something not quite right. This allows \n end rather than enforcing end
    -- Could check the \n is at the end of the string, using getOffset and getSource
    oneOf
        [ succeed (\i -> Done (List.reverse (i :: ints)))
            |= backtrackable int
            |. oneOf
                [ end
                , Parser.chompIf (\c -> c == '\n')
                ]
        , succeed (\i -> Loop (i :: ints))
            |= int
            |. chompWhile (\c -> c == ' ' || c == '\t')
        ]
