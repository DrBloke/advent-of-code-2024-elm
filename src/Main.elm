module Main exposing (main)

import Accessibility as Html exposing (Html, button, div, text)
import Accessibility.Aria as Aria
import Browser
import FontAwesome as Icon
import Helper.HtmlExtra as Html
import Helper.ParserExtra exposing (deadEndsToString)
import Html.Attributes as Attributes exposing (value)
import Html.Events as Events
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
        config =
            case model.page of
                RockPaperScissors ->
                    RockPaperScissors.config

        parsedInput =
            parseInput config model.inputData
    in
    div [ Attributes.class "container" ]
        [ div [ Attributes.class "top-header" ] [ Html.img "Elm logo" [ Attributes.width 30, Attributes.height 30, Attributes.src "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]" ], Html.h1 [] [ config |> Types.fromConfig |> .title |> text ] ]
        , div [ Attributes.class "panel-with-sidebar" ]
            [ accordion
                [ { identifier = "input-data"
                  , label = "Input data"
                  , content = div [ Attributes.class "input" ] [ input model.inputData parsedInput config ]
                  }
                ]
                model.expandedItems
            , div [ Attributes.class "output" ] [ output parsedInput config ]
            ]
        ]


accordion :
    List
        { identifier : String
        , label : String
        , content : Html Msg
        }
    -> Set String
    -> Html Msg
accordion items active =
    div [ Attributes.id "accordion-group", Attributes.class "accordion" ]
        (List.map
            (\{ identifier, label, content } ->
                let
                    headerId =
                        identifier ++ "-header-1"

                    panelId =
                        identifier ++ "-panel-1"

                    isActive =
                        Set.member identifier active

                    stateIcon =
                        -- Icon.icon Icon.minus
                        if isActive then
                            text "-"

                        else
                            text "+"
                in
                [ Html.h3 []
                    [ button
                        [ Attributes.id headerId
                        , Aria.expanded isActive
                        , Aria.controls [ panelId ]
                        , Events.onClick (ToggleAccordionItem identifier)
                        ]
                        [ Html.span [] [ text label ], Html.span [] [ stateIcon ] ]
                    ]
                , Html.section
                    [ Attributes.id panelId, Aria.labeledBy headerId, Attributes.hidden isActive ]
                    [ content ]
                ]
            )
            items
            |> List.concat
        )


parseInput : Config a b -> String -> Result String a
parseInput (Config config) inputData =
    Parser.run config.parser inputData
        |> Result.mapError deadEndsToString


input : String -> Result String a -> Config a b -> Html Msg
input inputData parsedInput (Config config) =
    let
        errorConfig =
            case parsedInput of
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

            -- , Attributes.cols 30
            , Attributes.class errorConfig.class
            , Events.onInput TextareaMsg
            ]
            [ Html.text inputData ]
        , errorConfig.content
        ]


output : Result String a -> Config a b -> Html Msg
output parsedInput (Config config) =
    case parsedInput of
        Ok value ->
            value
                |> config.converter
                |> config.render
                |> Html.map (\_ -> NoOp)

        Err _ ->
            div [] [ text "The input data is invalid" ]
