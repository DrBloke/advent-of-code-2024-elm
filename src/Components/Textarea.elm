module Components.Textarea exposing (view)

import Accessibility as Html exposing (Html)
import Helper.HtmlExtra as Html
import Html.Attributes as Attributes
import Html.Events as Events


type alias Configuration =
    { identifier : String
    , inputLabel : String
    }


view :
    Configuration
    -> String
    -> Result String a
    -> (String -> msg)
    -> Html msg
view config inputData parsedInput msg =
    let
        errorConfig =
            case parsedInput of
                Ok _ ->
                    { class = "valid"
                    , content = Html.none
                    }

                Err error ->
                    { class = "invalid"
                    , content = Html.div [ Attributes.class "error" ] [ Html.text error ]
                    }

        textareaId =
            config.identifier ++ "-textarea"
    in
    Html.div [ Attributes.class "textarea-field" ]
        [ Html.label [ Attributes.for textareaId ] [ Html.text config.inputLabel ]
        , Html.textarea
            [ Attributes.id textareaId
            , Attributes.rows 10
            , Attributes.class errorConfig.class
            , Events.onInput msg
            ]
            [ Html.text inputData ]
        , errorConfig.content
        ]
