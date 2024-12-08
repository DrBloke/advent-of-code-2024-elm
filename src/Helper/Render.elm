module Helper.Render exposing (..)

import Html exposing (Html)


intWithMessage : String -> Int -> Html ()
intWithMessage leadingMessage =
    String.fromInt
        >> Html.text
        >> (\a ->
                Html.div []
                    [ Html.text (leadingMessage ++ ": ")
                    , Html.strong [] [ a ]
                    ]
           )
