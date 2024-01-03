module Layouts.Sidebar exposing (view)

import Accessibility as Html exposing (Html)
import Html.Attributes as Attributes



{- Sidebar layout. A responsive, max-with sidebar and notSidebar which expands to fill remaining space
   To set max with of sidebar change .panel-with-sidebar>:first-child flex-basis
   To set min size of notSidebar, change .panel-with-sidebar>:last-child min-inline-size
-}


view : Html msg -> Html msg -> Html msg
view sidebar notSidebar =
    Html.div [ Attributes.class "panel-with-sidebar" ] [ sidebar, notSidebar ]
