module Main exposing (main)

import Browser
import Helper.HtmlExtra as Html
import Helper.ParserExtra exposing (deadEndsToString)
import Html exposing (Html, button, div, text)
import Html.Attributes as Attributes exposing (value)
import Html.Events as Events
import Parser
import RockPaperScissors
import Types exposing (Config(..), fromConfig)



-- MAIN


main =
    Browser.sandbox { init = init RockPaperScissors, update = update, view = view }



-- MODEL


type Page
    = RockPaperScissors


type alias Model =
    { page : Page
    , inputData : String
    }


init : Page -> Model
init page =
    case page of
        RockPaperScissors ->
            { page = RockPaperScissors
            , inputData =
                RockPaperScissors.config
                    |> fromConfig
                    |> .defaultInput
            }



-- UPDATE


type Msg
    = Goto Page
    | TextareaMsg String
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        Goto page ->
            { model | page = page }

        TextareaMsg value ->
            { model | inputData = value }

        NoOp ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    let
        config =
            case model.page of
                RockPaperScissors ->
                    RockPaperScissors.config
    in
    div []
        [ input model.inputData config
        , output model.inputData config
        ]


parseInput : String -> Config a b -> Result String a
parseInput inputData (Config config) =
    Parser.run config.parser inputData
        |> Result.mapError deadEndsToString


input : String -> Config a b -> Html Msg
input inputData ((Config config) as wrappedConfig) =
    let
        errorConfig =
            case parseInput inputData wrappedConfig of
                Ok _ ->
                    { class = "valid"
                    , content = Html.none
                    }

                Err error ->
                    { class = "invalid"
                    , content = Html.div [ Attributes.class "error" ] [ text error ]
                    }

        textareaId =
            config.identifier ++ "-textarea"
    in
    div [ Attributes.class "field" ]
        [ Html.label [ Attributes.for textareaId ] [ Html.text config.inputLabel ]
        , Html.textarea
            [ Attributes.id textareaId
            , Attributes.rows 10
            , Attributes.cols 30
            , Attributes.class errorConfig.class
            , Events.onInput TextareaMsg
            ]
            [ Html.text inputData ]
        , errorConfig.content
        ]


output : String -> Config a b -> Html Msg
output inputData ((Config config) as wrappedConfig) =
    case parseInput inputData wrappedConfig of
        Ok value ->
            value
                |> config.converter
                |> config.render
                |> Html.map (\_ -> NoOp)

        Err _ ->
            div [] [ text "The input data is invalid" ]
