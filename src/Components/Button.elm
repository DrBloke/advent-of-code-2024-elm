module Components.Button exposing
    ( Button
    , Configuration
    , Label(..)
    , asComponent
    , configuration
    , view
    )

import Components.Component as Component exposing (Component)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode


type Configuration msg
    = Configuration (Config msg)


type alias Config msg =
    { onClick : msg
    , label : Label
    }


type alias DefaultConfig msg =
    { onClick : msg
    , label : Label
    }


configuration : DefaultConfig msg -> Configuration msg
configuration config =
    Configuration config


type Label
    = TextOnly String
    | Link String


view : Configuration msg -> Html msg
view (Configuration config) =
    case config.label of
        Link label ->
            Html.a [ Events.preventDefaultOn "click" (Decode.succeed ( config.onClick, True )) ]
                [ Html.text label ]

        TextOnly label ->
            Html.button
                [ Events.onClick config.onClick
                , Attributes.class "button"
                ]
                [ Html.text label ]


type alias Button msg =
    Component msg


asComponent : Configuration msg -> Button msg
asComponent config =
    view config
        |> Component.toComponent
