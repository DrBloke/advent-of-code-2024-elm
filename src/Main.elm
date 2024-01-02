module Main exposing (main)

import Accessibility as Html exposing (Html)
import Browser
import Components.Accordion as Accordion
import Components.Textarea as Textarea
import Helper.HtmlExtra as Html
import Helper.ParserExtra exposing (deadEndsToString)
import Html.Attributes as Attributes exposing (value)
import Markdown
import Parser
import RockPaperScissors
import Set exposing (Set)
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
    , expandedItems : Set String
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
            , expandedItems = Set.fromList [ "input-data" ]
            }



-- UPDATE


type Msg
    = Goto Page
    | TextareaMsg String
    | ToggleAccordionItem String
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        Goto page ->
            { model | page = page }

        TextareaMsg value ->
            { model | inputData = value }

        ToggleAccordionItem identifier ->
            if Set.member identifier model.expandedItems then
                { model | expandedItems = Set.remove identifier model.expandedItems }

            else
                { model | expandedItems = Set.insert identifier model.expandedItems }

        NoOp ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    let
        wrappedConfig =
            case model.page of
                RockPaperScissors ->
                    RockPaperScissors.config

        config =
            Types.fromConfig wrappedConfig

        parsedInput =
            parseInput wrappedConfig model.inputData
    in
    Html.div [ Attributes.class "container" ]
        [ Html.div [ Attributes.class "top-header" ] [ Html.img "Elm logo" [ Attributes.width 30, Attributes.height 30, Attributes.src "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]" ], Html.h1 [] [ config |> .title |> Html.text ] ]
        , Html.div [ Attributes.class "panel-with-sidebar" ]
            [ Accordion.view
                [ { identifier = "description"
                  , label = "The problem"
                  , content = Html.div [ Attributes.class "description" ] [ Markdown.toHtml [] <| config.description ]
                  }
                , { identifier = "input-data"
                  , label = "Input data"
                  , content = Html.div [ Attributes.class "input" ] [ Textarea.view { identifier = config.identifier, inputLabel = config.inputLabel } model.inputData parsedInput TextareaMsg ]
                  }
                ]
                model.expandedItems
                ToggleAccordionItem
            , Html.div [ Attributes.class "output" ] [ output parsedInput wrappedConfig ]
            ]
        ]


parseInput : Config a b -> String -> Result String a
parseInput (Config config) inputData =
    Parser.run config.parser inputData
        |> Result.mapError deadEndsToString


output : Result String a -> Config a b -> Html Msg
output parsedInput (Config config) =
    case parsedInput of
        Ok value ->
            value
                |> config.converter
                |> config.render
                |> Html.map (\_ -> NoOp)

        Err _ ->
            Html.div [] [ Html.text "The input data is invalid" ]
