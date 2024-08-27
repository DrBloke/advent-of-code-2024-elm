module Components.Notification exposing (view)

import Accessibility as Html exposing (Html)
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes


view : Maybe String -> Html msg
view maybeNotification =
    case maybeNotification of
        Just str ->
            Html.div [ Attributes.class "notification--warning" ] [ Html.text str ]

        Nothing ->
            Html.none
