module Page.Index exposing (view)

import Accessibility as Html exposing (Html)
import Html as HtmlUnsafe
import Html.Attributes as Attributes
import Route


view : Maybe String -> Html msg
view notification =
    Html.div [ Attributes.class "index" ]
        [ Html.text (Maybe.withDefault "" notification)
        , Html.a [ Attributes.href (Route.pageToPath Route.RockPaperScissors) ] [ Html.text "Rock paper scissors" ]
        ]
