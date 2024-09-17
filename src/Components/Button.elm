module Components.Button exposing
    ( Button
    , Configuration
    , Label(..)
    , asComponent
    , configuration
    , view
    )

import Accessibility as Html exposing (Html)
import Components.Component as Component exposing (Component)
import Html.Attributes as Attributes
import Html.Events as Events


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


view : Configuration msg -> Html msg
view (Configuration config) =
    Html.button
        [ Events.onClick config.onClick
        , Attributes.class "button"
        ]
        [ labelView config.label ]


labelView : Label -> Html msg
labelView labelConfig =
    case labelConfig of
        TextOnly labelText ->
            Html.text labelText


type alias Button msg =
    Component msg


asComponent : Configuration msg -> Button msg
asComponent config =
    view config
        |> Component.toComponent
