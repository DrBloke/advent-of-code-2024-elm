module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import RockPaperScissors exposing (rockPaperScissors)



-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type Model = RockPaperScissorsView


init : Model
init =
  RockPaperScissorsView



-- UPDATE


type Msg
  = RockPaperScissors


update : Msg -> Model -> Model
update msg model =
  case msg of
    RockPaperScissors ->
        RockPaperScissorsView



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    RockPaperScissorsView ->
        Html.map (\_ -> RockPaperScissors) rockPaperScissors