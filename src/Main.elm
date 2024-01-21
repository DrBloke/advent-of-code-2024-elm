port module Main exposing (..)

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
                        RockPaperScissors.config
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

        NotFoundModel _ ->
            case msg of
                UrlChanged page ->
                    init page

                _ ->
                    Update.pure IndexModel



-- VIEW


view : Model -> Html Msg
view model_ =
    case model_ of
        PageModel model ->
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

        IndexModel ->
            Accessibility.text "Hello"

        NotFoundModel path ->
            Accessibility.text (String.replace "{{path}}" path """The path "/{{path}}" does not exist.""")


subscriptions : Model -> Sub Msg
subscriptions _ =
    onUrlChange UrlChanged



-- PORTS


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg
