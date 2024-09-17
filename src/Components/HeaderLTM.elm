module Components.HeaderLTM exposing (Configuration, configuration, view)

import Accessibility as Html exposing (Html)
import Components.Button as Button exposing (Button)
import Components.Component as Component
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes



-- A Header with Logo, Title and menu burger


type Configuration msg
    = Configuration (Config msg)


type alias Config msg =
    { button : Button msg
    }


type alias DefaultConfig msg =
    { button : Button msg }


configuration : DefaultConfig msg -> Configuration msg
configuration config =
    Configuration config


view : Configuration msg -> { title : String, logoAltText : String, logoSrc : String } -> Html msg
view (Configuration config) { title, logoAltText, logoSrc } =
    Html.div [ Attributes.class "header-with-logo-title-menu" ]
        [ Html.img logoAltText
            [ Attributes.width 30
            , Attributes.height 30
            , Attributes.src logoSrc
            ]
        , Html.h1 [] [ Html.text title ]
        , Component.toHtml config.button
        ]
