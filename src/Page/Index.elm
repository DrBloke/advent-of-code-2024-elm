module Page.Index exposing (view)

import Accessibility as Html exposing (Html)
import Components.Button as Button
import Components.Notification as Notification
import Html.Attributes as Attributes
import Route
import Types


view : (String -> msg) -> Maybe String -> Html msg
view pushUrl notification =
    Html.div [ Attributes.class "index" ]
        (Notification.view notification
            :: List.map
                (\config ->
                    Html.div []
                        [ Button.configuration
                            { onClick = pushUrl (Types.identifier config), label = Button.Link (Types.title config) }
                            |> Button.view
                        ]
                )
                Route.allConfigs
        )
