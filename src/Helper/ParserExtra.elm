module Helper.ParserExtra exposing (deadEndsToString)

import Parser exposing (DeadEnd)


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
