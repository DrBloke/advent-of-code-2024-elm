module Components.ConditionalContent exposing (view)

import Accessibility as Html exposing (Html)
import Html.Attributes as Attributes


view : Result String (Html a) -> Maybe String -> (a -> msg) -> Html msg
view contentOrError errorMessage msg =
    let
        content =
            case contentOrError of
                Ok html ->
                    Html.map msg html

                Err _ ->
                    Maybe.withDefault "The input data is invalid" errorMessage
                        |> Html.text
    in
    Html.div [ Attributes.class "conditional-content" ] [ content ]
