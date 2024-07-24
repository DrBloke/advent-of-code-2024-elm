port module Main exposing (..)

import Accessibility exposing (Html)
import Browser
import Components.Accordion as Accordion
import Components.ConditionalContent as ConditionalContent
import Components.HeaderLTM as HeaderLTM
import Components.Textarea as Textarea
import Helper.ParserExtra exposing (deadEndsToString)
import Layouts.WrapperHeader as WrapperHeader
import Layouts.WrapperHeaderSidebar as WrapperHeaderSidebar
import Markdown
import Page.Index
import Page.RockPaperScissors
import Parser
import Route exposing (Page(..), Route(..))
import Set exposing (Set)
import Types exposing (Config(..), fromConfig)
import Update2 as Update



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type Model
    = PageModel
        { page : Page
        , inputData : String
        , expandedItems : Set String
        }
    | IndexModel
    | NotFoundModel String


init : String -> ( Model, Cmd Msg )
init url =
    case Route.toRoute url of
        Route RockPaperScissors ->
            Update.pure
                (PageModel
                    { page = RockPaperScissors
                    , inputData =
                        Page.RockPaperScissors.config
                            |> fromConfig
                            |> .defaultInput
                    , expandedItems = Set.fromList [ "input-data" ]
                    }
                )

        Index ->
            Update.pure IndexModel

        NotFound path ->
            Update.pure (NotFoundModel path)



-- UPDATE


type Msg
    = UrlChanged String
    | TextareaMsg String
    | ToggleAccordionItem String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model_ =
    case model_ of
        PageModel model ->
            case msg of
                UrlChanged page ->
                    init page

                TextareaMsg value ->
                    Update.pure (PageModel { model | inputData = value })

                ToggleAccordionItem identifier ->
                    Update.pure
                        (PageModel
                            (if Set.member identifier model.expandedItems then
                                { model | expandedItems = Set.remove identifier model.expandedItems }

                             else
                                { model | expandedItems = Set.insert identifier model.expandedItems }
                            )
                        )

                NoOp ->
                    Update.pure (PageModel model)

        IndexModel ->
            case msg of
                UrlChanged page ->
                    init page

                _ ->
                    Update.pure IndexModel

        NotFoundModel path ->
            case msg of
                UrlChanged page ->
                    init page

                _ ->
                    Update.pure (NotFoundModel path)



-- VIEW


view : Model -> Html Msg
view model_ =
    case model_ of
        PageModel model ->
            let
                wrappedConfig =
                    Route.pageToConfig model.page

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
                                    { identifier = config.identifier
                                    , inputLabel = config.inputLabel
                                    }
                                    model.inputData
                                    parsedInput
                                    TextareaMsg
                          }
                        ]
                        model.expandedItems
                        ToggleAccordionItem

                output =
                    ConditionalContent.view parsedInput Nothing (\_ -> NoOp)

                header =
                    HeaderLTM.view
                        { logoAltText = "Elm logo"
                        , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                        , title = config.title
                        }
            in
            WrapperHeaderSidebar.view { header = header, sidebar = accordion, notSidebar = output }

        IndexModel ->
            let
                header =
                    HeaderLTM.view
                        { logoAltText = "Elm logo"
                        , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                        , title = "Advent of Code 2022"
                        }

                content =
                    Page.Index.view Nothing
            in
            WrapperHeader.view { header = header, content = content }

        NotFoundModel path ->
            let
                header =
                    HeaderLTM.view
                        { logoAltText = "Elm logo"
                        , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                        , title = "Advent of Code 2022"
                        }

                content =
                    String.replace "{{path}}" path """The path "/{{path}}" does not exist."""
                        |> Accessibility.text
            in
            WrapperHeader.view { header = header, content = content }


subscriptions : Model -> Sub Msg
subscriptions _ =
    onUrlChange UrlChanged



-- PORTS


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg
