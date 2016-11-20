module Analyzer exposing (generateCrossword, Solution, Problem)

import String
import List
import Lazy.List as LL
import List.Extra

type alias WordPadding = (String, Int)
type alias Solution = List WordPadding
type alias Problem = (List String, String )

generateCrossword : Problem -> LL.LazyList Solution
generateCrossword (words, keyword) = case words of
  [] -> LL.empty
  _ -> let
    paddings =
      List.Extra.zip words (String.toList keyword) |>
      List.filterMap (\(word, letter) ->
          List.Extra.elemIndex letter (String.toList word) |>
          Maybe.map (\i -> (word, i))
        ) in
    if String.length keyword <= List.length paddings then LL.singleton paddings
    else LL.empty
