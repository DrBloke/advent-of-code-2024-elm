module Helper.ParserExtra exposing
    ( TwoColumnsOfInts
    , deadEndsToString
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
                    "ExpectingInt at " ++ position

                Parser.ExpectingHex ->
                    "ExpectingHex at " ++ position

                Parser.ExpectingOctal ->
                    "ExpectingOctal at " ++ position

                Parser.ExpectingBinary ->
                    "ExpectingBinary at " ++ position

                Parser.ExpectingFloat ->
                    "ExpectingFloat at " ++ position

                Parser.ExpectingNumber ->
                    "ExpectingNumber at " ++ position

                Parser.ExpectingVariable ->
                    "ExpectingVariable at " ++ position

                Parser.ExpectingSymbol str ->
                    "ExpectingSymbol " ++ str ++ " at " ++ position

                Parser.ExpectingKeyword str ->
                    "ExpectingKeyword " ++ str ++ " at " ++ position

                Parser.ExpectingEnd ->
                    "ExpectingEnd at " ++ position

                Parser.UnexpectedChar ->
                    "UnexpectedChar at " ++ position

                Parser.Problem str ->
                    "ProblemString " ++ str ++ " at " ++ position

                Parser.BadRepeat ->
                    "BadRepeat at " ++ position
    in
    List.foldl (++) "" (List.map deadEndToString deadEnds)


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
