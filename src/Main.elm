port module Main exposing (..)

import Accessibility exposing (Html)
import Browser
import Components.Accordion as Accordion
import Components.ConditionalContent as ConditionalContent
import Components.HeaderLTM as HeaderLTM
import Components.Textarea as Textarea
import Helper.ParserExtra exposing (deadEndsToString)
import Json.Decode as Decode
import Json.Encode as Encode
import Layouts.WrapperHeader as WrapperHeader
import Layouts.WrapperHeaderSidebar as WrapperHeaderSidebar
import Markdown
import Maybe.Extra as Maybe
import Page.Index
import Parser
import Route exposing (Route(..))
import Set exposing (Set)
import Types exposing (Config(..))
import Update2 as Update



-- MAIN


main : Program Encode.Value Model Msg
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


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    let
        { url, storedData } =
            case Decode.decodeValue decode flags of
                Ok flagsJson ->
                    flagsJson

                Err _ ->
                    { url = "", storedData = Nothing }
    in
    case Route.toRoute url of
        Page config ->
            Update.pure
                (PageModel
                    { pageConfig = config
                    , inputData = Maybe.withDefault (Types.defaultInput config) storedData
                    , expandedItems = Set.fromList [ "input-data" ]
                    }
                )
                |> addCmd (setTitle (Types.title config))

        Index ->
            Update.pure IndexModel

        NotFound path ->
            Update.pure (NotFoundModel path)



-- UPDATE


type Msg
    = UrlChanged Encode.Value
    | PushUrl String
    | TextareaMsg String
    | ToggleAccordionItem String
    | NoOp


addCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd cmd ( model, oldCmd ) =
    ( model, Cmd.batch [ oldCmd, cmd ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model_ =
    case model_ of
        PageModel model ->
            case msg of
                UrlChanged page ->
                    init page

                PushUrl url ->
                    Update.pure IndexModel
                        |> addCmd (pushUrl url)

                TextareaMsg value ->
                    Update.pure (PageModel { model | inputData = value })
                        |> (encocdeStoredData
                                { pathName = Types.identifier model.pageConfig
                                , data = value
                                }
                                |> setStorage
                                |> addCmd
                           )

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

                PushUrl url ->
                    Update.pure IndexModel
                        |> addCmd (pushUrl url)

                _ ->
                    Update.pure IndexModel

        NotFoundModel path ->
            case msg of
                UrlChanged page ->
                    init page

                PushUrl url ->
                    Update.pure IndexModel
                        |> addCmd (pushUrl url)

                _ ->
                    Update.pure (NotFoundModel path)



-- VIEW


view : Model -> Html Msg
view model_ =
    let
        header title pushUrl_ =
            HeaderLTM.view
                { logoAltText = "Elm logo"
                , logoSrc = "[VITE_PLUGIN_ELM_ASSET:./assets/Elm_logo.svg]"
                , title = title
                , pushUrl = pushUrl_
                }
    in
    case model_ of
        PageModel model ->
            let
                parsedInput =
                    Parser.run (Types.parser model.pageConfig) model.inputData
                        |> Result.mapError deadEndsToString

                -- |> Debug.log "parsed data"
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
            in
            WrapperHeaderSidebar.view { header = header (Types.title model.pageConfig) PushUrl, sidebar = accordion, notSidebar = output }

        IndexModel ->
            let
                content =
                    Page.Index.view PushUrl Nothing
            in
            WrapperHeader.view { header = header "Advent of Code 2022" PushUrl, content = content }

        NotFoundModel path ->
            let
                content =
                    String.replace "{{path}}" path """The path "/{{path}}" does not exist."""
                        |> Just
                        |> Page.Index.view PushUrl
            in
            WrapperHeader.view { header = header "Advent of Code 2022" PushUrl, content = content }


subscriptions : Model -> Sub Msg
subscriptions _ =
    onUrlChange UrlChanged



-- JSON ENCODE/DECODE


type alias Flags =
    { url : String
    , storedData : Maybe String
    }


type alias StoredData =
    { pathName : String
    , data : String
    }


encode : Flags -> Encode.Value
encode flags =
    Encode.object
        [ ( "url", Encode.string flags.url )
        , ( "storedData", Maybe.unwrap Encode.null Encode.string flags.storedData )
        ]


encocdeStoredData : StoredData -> Encode.Value
encocdeStoredData storedData =
    Encode.object
        [ ( "pathName", Encode.string storedData.pathName )
        , ( "data", Encode.string storedData.data )
        ]


decode : Decode.Decoder Flags
decode =
    Decode.map2 Flags
        (Decode.field "url" Decode.string)
        (Decode.field "storedData" Decode.string |> Decode.maybe)



-- PORTS


port onUrlChange : (Encode.Value -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


port setStorage : Encode.Value -> Cmd msg


port setTitle : String -> Cmd msg
