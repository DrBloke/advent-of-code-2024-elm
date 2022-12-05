module RockPaperScissors exposing (rockPaperScissors)

import Html exposing (Html, button, div, text)

testString= """
A Y
B X
C Z
"""

type Play = Rock |
 Paper | Scissors

type Round = Round Play Play

type ScoredRound = ScoredRound Round

type alias Game =
  { rounds: List Round
  , totalScore : Int
  }

type ElfCodedPlay = A | B | C
type MeCodedPlay = X | Y | Z



rockPaperScissors : Html ()
rockPaperScissors  =
  div [][text "Hello"]
   
