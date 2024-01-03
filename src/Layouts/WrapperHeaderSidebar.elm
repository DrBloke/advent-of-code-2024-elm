module Layouts.WrapperHeaderSidebar exposing (view)

import Accessibility as Html exposing (Html)
import Html.Attributes as Attributes
import Layouts.Sidebar as Sidebar



-- Page wrapper for a page with a header and a sidebar-layout


view : { header : Html msg, sidebar : Html msg, notSidebar : Html msg } -> Html msg
view { header, sidebar, notSidebar } =
    Html.div [ Attributes.class "header-and-main-with-sidebar" ]
        [ header
        , Html.main_ [] [ Sidebar.view sidebar notSidebar ]
        ]
