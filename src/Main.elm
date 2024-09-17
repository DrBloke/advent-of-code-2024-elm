port module Main exposing (..)

import Accessibility exposing (Html)
import Browser
import Components.Accordion as Accordion
import Components.Button as Button
import Components.ConditionalContent as ConditionalContent
import Components.HeaderLTM as HeaderLTM
import Components.Textarea as Textarea
import Helper.ParserExtra exposing (deadEndsToString)
import Layouts.WrapperHeader as WrapperHeader
import Layouts.WrapperHeaderSidebar as WrapperHeaderSidebar
import Markdown
import Page.Index
import Parser
import Route exposing (Route(..))
import Set exposing (Set)
import Types exposing (Config(..))
import Update2 as Update



-- MAIN


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = PageModel
        { pageConfig : Config
        , inputData : String
        , expandedItems : Set String
        }
    | IndexModel
    | NotFoundModel String


init : String -> ( Model, Cmd Msg )
init url =
    case Route.toRoute url of
        Page config ->
            Update.pure
                (PageModel
                    { pageConfig = config
                    , inputData = Types.defaultInput config
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
                parsedInput =
                    Parser.run (Types.parser model.pageConfig) model.inputData
                        |> Result.mapError deadEndsToString

                accordion =
                    Accordion.view
                        [ { identifier = "description"
                          , label = "The problem"
                          , content = Markdown.toHtml [] (Types.description model.pageConfig)
                          }
                        , { identifier = "input-data"
                          , label = "Input data"
                          , content =
                                Textarea.view
                                    { identifier = Types.identifier model.pageConfig
                                    , inputLabel = Types.inputLabel model.pageConfig
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

                headerButton =
                    { onClick = UrlChanged ""
                    , label = Button.TextOnly "Menu"
                    }
                        |> Button.configuration
                        |> Button.asComponent

                headerConfig =
                    { button = headerButton }
                        |> HeaderLTM.configuration

                header =
                    HeaderLTM.view headerConfig
                        { logoAltText = "Elm logo"
                        , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                        , title = Types.title model.pageConfig
                        }
            in
            WrapperHeaderSidebar.view { header = header, sidebar = accordion, notSidebar = output }

        IndexModel ->
            let
                headerButton =
                    { onClick = UrlChanged ""
                    , label = Button.TextOnly "Menu"
                    }
                        |> Button.configuration
                        |> Button.asComponent

                headerConfig =
                    { button = headerButton }
                        |> HeaderLTM.configuration

                header =
                    HeaderLTM.view headerConfig
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
                headerButton =
                    { onClick = UrlChanged ""
                    , label = Button.TextOnly "Menu"
                    }
                        |> Button.configuration
                        |> Button.asComponent

                headerConfig =
                    { button = headerButton }
                        |> HeaderLTM.configuration

                header =
                    HeaderLTM.view headerConfig
                        { logoAltText = "Elm logo"
                        , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                        , title = "Advent of Code 2022"
                        }

                content =
                    String.replace "{{path}}" path """The path "/{{path}}" does not exist."""
                        |> Just
                        |> Page.Index.view
            in
            WrapperHeader.view { header = header, content = content }


subscriptions : Model -> Sub Msg
subscriptions _ =
    onUrlChange UrlChanged



-- PORTS


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg
