module Main exposing (main)

import Accessibility exposing (Html)
import Browser
import Components.Accordion as Accordion
import Components.ConditionalContent as ConditionalContent
import Components.HeaderLTM as HeaderLTM
import Components.Textarea as Textarea
import Helper.ParserExtra exposing (deadEndsToString)
import Layouts.WrapperHeaderSidebar as WrapperHeaderSidebar
import Markdown
import Parser
import RockPaperScissors
import Set exposing (Set)
import Types exposing (Config(..), fromConfig)
import Update2 as Update



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type Page
    = RockPaperScissors


type alias Model =
    { page : Page
    , inputData : String
    , expandedItems : Set String
    }


urlToPage : String -> Page
urlToPage url =
    case url of
        "rock-paper-scissors" ->
            RockPaperScissors

        _ ->
            RockPaperScissors


init : String -> ( Model, Cmd Msg )
init url =
    case urlToPage url of
        RockPaperScissors ->
            Update.pure
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Goto page ->
            Update.pure
                { model | page = page }

        TextareaMsg value ->
            Update.pure
                { model | inputData = value }

        ToggleAccordionItem identifier ->
            Update.pure
                (if Set.member identifier model.expandedItems then
                    { model | expandedItems = Set.remove identifier model.expandedItems }

                 else
                    { model | expandedItems = Set.insert identifier model.expandedItems }
                )

        NoOp ->
            Update.pure model



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
            Parser.run config.parser model.inputData
                |> Result.mapError deadEndsToString

        accordion =
            Accordion.view
                [ { identifier = "description"
                  , label = "The problem"
                  , content = Markdown.toHtml [] config.description
                  }
                , { identifier = "input-data"
                  , label = "Input data"
                  , content =
                        Textarea.view
                            { identifier = config.identifier, inputLabel = config.inputLabel }
                            model.inputData
                            parsedInput
                            TextareaMsg
                  }
                ]
                model.expandedItems
                ToggleAccordionItem

        output =
            let
                contentOrError =
                    Result.map config.render parsedInput
            in
            ConditionalContent.view contentOrError Nothing (\_ -> NoOp)

        header =
            HeaderLTM.view { logoAltText = "Elm logo", logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]", title = config.title }
    in
    WrapperHeaderSidebar.view { header = header, sidebar = accordion, notSidebar = output }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
