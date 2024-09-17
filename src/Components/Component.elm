module Components.Component exposing
    ( Component
    , toComponent
    , toHtml
    )

import Accessibility exposing (Html)


type Component msg
    = Component (Html msg)


toComponent : Html msg -> Component msg
toComponent =
    Component


toHtml : Component msg -> Html msg
toHtml (Component html) =
    html
