module RockPaperScissors exposing (config, rockPaperScissors)

import Helper.ParserExtra exposing (deadEndsToString)
import Html exposing (Html, div, text)
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , end
        , float
        , keyword
        , loop
        , map
        , oneOf
        , spaces
        , succeed
        , symbol
        )
import Types exposing (Config(..))


config : Config Int Int
config =
    Config
        { parser = parseTotalScore
        , converter = identity
        , render = render
        , defaultInput = testString
        }


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
    = ScoredRound Play Play Int


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


outputOld =
    Parser.run parseTotalScore testString


playToString : Play -> String
playToString play =
    case play of
        Rock ->
            "R"

        Paper ->
            "P"

        Scissors ->
            "S"


parseTotalScore : Parser Int
parseTotalScore =
    loop 0 scoreHelper


scoreHelper : Int -> Parser (Step Int Int)
scoreHelper totalScore =
    let
        _ =
            Debug.log "totalScore" totalScore
    in
    oneOf
        [ succeed (\score -> Loop (score + totalScore))
            |= map (\(ScoredRound _ _ s) -> s) parseScoredRound
            |. spaces
        , succeed ()
            |> map (\_ -> Done totalScore)
        ]


parseScoredRound : Parser ScoredRound
parseScoredRound =
    Parser.succeed
        (\elf me ->
            let
                choiceScore =
                    case me of
                        Rock ->
                            1

                        Paper ->
                            2

                        Scissors ->
                            3

                resultScore =
                    if
                        (elf == Rock && me == Paper)
                            || (elf == Paper && me == Scissors)
                            || (elf == Scissors && me == Rock)
                    then
                        6

                    else if
                        (elf == Rock && me == Rock)
                            || (elf == Paper && me == Paper)
                            || (elf == Scissors && me == Scissors)
                    then
                        3

                    else if
                        (elf == Paper && me == Rock)
                            || (elf == Scissors && me == Paper)
                            || (elf == Rock && me == Scissors)
                    then
                        0

                    else
                        {- shouldn't reach here. Could use nested case statementto ensure everything is being considered,
                           but it's not as succinct
                        -}
                        -1
            in
            ScoredRound elf me (choiceScore + resultScore) |> Debug.log "scoring"
        )
        |. spaces
        |= parseElf
        |. spaces
        |= parseMe


parseElf : Parser Play
parseElf =
    oneOf
        [ map (\_ -> Rock) (symbol "A")
        , map (\_ -> Paper) (symbol "B")
        , map (\_ -> Scissors) (symbol "C")
        ]


parseMe : Parser Play
parseMe =
    oneOf
        [ map (\_ -> Rock) (symbol "X")
        , map (\_ -> Paper) (symbol "Y")
        , map (\_ -> Scissors) (symbol "Z")
        ]


rockPaperScissors : Html ()
rockPaperScissors =
    case outputOld of
        Ok score ->
            div [] [ text <| String.fromInt score ]

        Err error ->
            div [] [ text (deadEndsToString error) ]


render : Int -> Html ()
render output =
    div [] [ text <| String.fromInt output ]
