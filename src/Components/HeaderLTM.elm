module Components.HeaderLTM exposing (view)

import Accessibility as Html exposing (Html)
import Components.Button as Button
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes



-- A Header with Logo, Title and menu burger


view : { title : String, logoAltText : String, logoSrc : String, pushUrl : String -> msg } -> Html msg
view { title, logoAltText, logoSrc, pushUrl } =
    Html.div [ Attributes.class "header-with-logo-title-menu" ]
        [ Html.img logoAltText
            [ Attributes.width 30
            , Attributes.height 30
            , Attributes.src logoSrc
            ]
        , Html.h1 [] [ Html.text title ]
        , Button.configuration { onClick = pushUrl "/", label = Button.Link "Menu" }
            |> Button.view
        ]
