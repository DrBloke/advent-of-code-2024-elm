module Layouts.Sidebar exposing (view)

import Accessibility as Html exposing (Html)
import Html.Attributes as Attributes


view : Html msg -> Html msg -> Html msg
view sidebar notSidebar =
    Html.div [ Attributes.class "panel-with-sidebar" ] [ sidebar, notSidebar ]
