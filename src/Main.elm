module Main exposing (main)

import Browser
import Helper.ParserExtra exposing (deadEndsToString)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Parser
import RockPaperScissors
import Types exposing (Config(..))



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type Model
    = RockPaperScissors


init : Model
init =
    RockPaperScissors



-- UPDATE


type alias Msg =
    ()


update : Msg -> Model -> Model
update _ model =
    case model of
        RockPaperScissors ->
            RockPaperScissors



-- VIEW


view : Model -> Html ()
view model =
    let
        config =
            case model of
                RockPaperScissors ->
                    RockPaperScissors.config |> Types.fromConfig
    in
    case Parser.run config.parser config.defaultInput of
        Ok parserOutput ->
            config.render parserOutput

        Err error ->
            div [] [ text (deadEndsToString error) ]
