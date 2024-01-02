module Components.Accordion exposing (view)

import Accessibility as Html exposing (Html)
import Accessibility.Aria as Aria
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes
import Html.Events as Events
import Set exposing (Set)


type alias Identifier =
    String


view :
    List
        { identifier : Identifier
        , label : String
        , content : Html msg
        }
    -> Set Identifier
    -> (String -> msg)
    -> Html msg
view items expandedItems msg =
    Html.div [ Attributes.id "accordion-group", Attributes.class "accordion" ]
        (List.map
            (\{ identifier, label, content } ->
                let
                    headerId =
                        identifier ++ "-header"

                    panelId =
                        identifier ++ "-panel"

                    isActive =
                        Set.member identifier expandedItems

                    stateIcon =
                        -- Icon.icon Icon.minus
                        if isActive then
                            Html.text "-"

                        else
                            Html.text "+"
                in
                [ Html.h3 []
                    [ Html.button
                        [ Attributes.id headerId
                        , Aria.expanded isActive
                        , Aria.controls [ panelId ]
                        , Events.onClick (msg identifier)
                        ]
                        [ Html.span [ Attributes.class "accordion-label" ] [ Html.text label ], Html.span [] [ stateIcon ] ]
                    ]
                , Html.section
                    [ Attributes.id panelId, Aria.labeledBy headerId, Attributes.hidden (not isActive) ]
                    [ content ]
                ]
            )
            items
            |> List.concat
        )
