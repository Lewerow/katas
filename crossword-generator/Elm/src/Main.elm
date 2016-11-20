module App exposing (..)

import Html
import Html.Attributes
import List
import String
import Task
import Maybe.Extra

import Analyzer

words = ["ALA", "KOTA", "KOZA"]
keyword = "LOK"

type alias CrosswordKeys = {
  keyword : String
  , words : List String
  }

type alias CrosswordWord = {
  word: String
  , startColumn: Int
  }

type alias CrosswordStructure = {
  words: List CrosswordWord
  , keywordColumn: Int
  , totalColumns: Int
}

type alias Model = {keys: CrosswordKeys, structure:CrosswordStructure}
type Msg = Reanalyze Analyzer.Problem

main: Program Never Model Msg
main = Html.program {
  init = init,
  view = view,
  update = update,
  subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  []

init : (Model, Cmd Msg)
init = ({keys={keyword="", words=[]},
  structure=noStructure},
  Task.perform (\_ -> Reanalyze (["ALA","KOT","KOZA"], "AOZ")) (Task.succeed ()))

update msg model = (newCrossword msg, Cmd.none)

newCrossword : Msg -> Model
newCrossword (Reanalyze (newWords, newKeyword)) =
  ({
    keys={keyword=newKeyword, words=newWords}
    , structure=makeStructure newWords newKeyword
  })

makeStructure words keyword =
  let solution = Analyzer.generateCrossword (words, keyword) in
  Maybe.Extra.unwrap noStructure (\s -> {
    words=List.map (\(w, p) -> {word=w, startColumn=5-p}) s,
    keywordColumn=5,
    totalColumns=10
  }) solution

noStructure = {words=[],keywordColumn=5,totalColumns=10}

view : Model -> Html.Html Msg
view model =
  Html.table [Html.Attributes.id "crossword"] <| renderCrossword model.structure

renderCrossword : CrosswordStructure -> List (Html.Html Msg)
renderCrossword s = let
  render = renderWord s.keywordColumn s.totalColumns in
  List.map render s.words

renderWord keywordColumn totalColumns crosswordWord =
  Html.tr [Html.Attributes.class "word"] <|
    (renderEmptyBlock crosswordWord.startColumn ++
      renderLetters crosswordWord.word (keywordColumn - crosswordWord.startColumn) ++
      renderEmptyBlock (totalColumns - String.length crosswordWord.word - crosswordWord.startColumn)
    )

renderLetters word keywordLocation =
  List.indexedMap (\index x -> (x, index == keywordLocation)) (String.toList word) |>
  List.map (\(l, isKeyword) -> Html.td
    ([ Html.Attributes.class "cell", Html.Attributes.class "letter" ] ++
      if isKeyword then [ Html.Attributes.class "keyword" ] else [])
    [ Html.text <| String.fromChar l ])

renderEmptyBlock k =
  Html.td [Html.Attributes.class "cell"] [] |> List.repeat k
