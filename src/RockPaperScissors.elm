module RockPaperScissors exposing (rockPaperScissors)

import Html exposing (Html, button, div, text)
import Parser exposing (Parser, (|.), (|=), succeed, symbol, float, spaces, map, oneOf, keyword)


testString =
    """
A Y
B X
C Z
"""


type Play
    = Rock
    | Paper
    | Scissors


type Round
    = Round Play Play


type ScoredRound
    = ScoredRound Round


type alias Game =
    { rounds : List ScoredRound
    , totalScore : Int
    }


type ElfCodedPlay
    = A
    | B
    | C


type MeCodedPlay
    = X
    | Y
    | Z

output =Parser.run parseRound "A X"

playToString: Play -> String
playToString play =
  case play of 
    Rock -> "R"
    Paper -> "P"
    Scissors -> "S"

parseRound: Parser Round
parseRound =
  Parser.succeed Round
      |= parseElf 
      |. spaces
      |= parseMe 

parseElf: Parser Play
parseElf =
  oneOf
    [ map (\_ -> Rock ) (symbol "A")
    , map (\_ -> Paper ) (symbol "B")
    , map (\_ -> Scissors ) (symbol "C")
    ]

parseMe: Parser Play
parseMe =
  oneOf
    [ map (\_ -> Rock ) (symbol "X")
    , map (\_ -> Paper ) (symbol "Y")
    , map (\_ -> Scissors ) (symbol "Z")
    ]


rockPaperScissors : Html ()
rockPaperScissors =
  case output of
    Ok (Round elf me) ->
      div [] [ text (playToString elf ++ " " ++ playToString me ) ]
    Err error ->
      div [] [ text (deadEndsToString error)]

---------------
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
                    "ExpectingKeyword " ++ str ++ "at " ++ position

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
