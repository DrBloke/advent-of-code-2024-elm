module Components.HeaderLTM exposing (view)

import Accessibility as Html exposing (Html)
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes



-- TODO: menu. Will be a msg passed in
-- A Header with Logo, Title and menu burger


view : { title : String, logoAltText : String, logoSrc : String } -> Html msg
view { title, logoAltText, logoSrc } =
    Html.div [ Attributes.class "header-with-logo-title-menu" ]
        [ Html.img logoAltText [ Attributes.width 30, Attributes.height 30, Attributes.src logoSrc ], Html.h1 [] [ Html.text title ] ]
