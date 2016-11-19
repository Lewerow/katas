module Analyzer exposing (generateCrossword)

import String
import List
import List.Extra
import Maybe.Extra

type alias WordPadding = (String, Int)
type alias Solution = List WordPadding

generateCrossword : List String -> String -> Maybe Solution
generateCrossword words keyword = case words of
  [] -> Nothing
  _ -> let
    paddings = List.map2
      (\word letter ->
        List.Extra.elemIndex letter (String.toList word) |>
        Maybe.map (\i -> (word, i))
      )
      words
      (String.toList keyword) in
    if String.length keyword <= List.length paddings then Maybe.Extra.combine paddings
    else Nothing