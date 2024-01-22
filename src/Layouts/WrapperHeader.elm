module Layouts.WrapperHeader exposing (view)

import Accessibility as Html exposing (Html)
import Html.Attributes as Attributes



-- Page wrapper for a page with a header


view : { header : Html msg, content : Html msg } -> Html msg
view { header, content } =
    Html.div [ Attributes.class "header-and-main" ]
        [ header, content ]
