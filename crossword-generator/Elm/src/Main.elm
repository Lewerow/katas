module App exposing (..)

import Html
import Html.Attributes
import List
import String
import Task
import Maybe.Extra exposing ((?))

import Analyzer

words = ["ALA", "KOTA", "KOZA"]
keyword = "LOK"

type alias CrosswordKeys = {
  keyword : String
  , words : List String
  }

type alias CrosswordWord = List (CellType, Maybe Char)
type alias CrosswordStructure = List CrosswordWord

type alias Model = {keys: CrosswordKeys, structure:CrosswordStructure}
type Msg = Reanalyze Analyzer.Problem
type CellType = Cell | Letter | Keyword

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
  Task.perform (\_ ->
    Reanalyze (["ALICJA","OWCA","KOZA", "PIES", "MRÓWKA", "MAMR"], "LCKIÓR"))
    (Task.succeed ())
  )

update msg model = (newCrossword msg, Cmd.none)

newCrossword : Msg -> Model
newCrossword (Reanalyze (newWords, newKeyword)) =
  ({
    keys={keyword=newKeyword, words=newWords}
    , structure=makeStructure newWords newKeyword
  })

noStructure = []

makeStructure words keyword =
  let solution = Analyzer.generateCrossword (words, keyword) in
  case solution of
    Nothing -> noStructure
    Just s -> let
      (keywordColumn, width) = getCrosswordWidth s
      toCells (w, p) =
        emptyCells (keywordColumn - p) ++
        List.indexedMap (\i l -> if i == p then (Keyword, Just l) else (Letter, Just l) ) (String.toList w) ++
        emptyCells (width - String.length w - keywordColumn + p) in
      List.map toCells s

emptyCells n = List.repeat n (Cell, Nothing)

getCrosswordWidth words =
  words |>
  List.map (\(w, p) -> ((String.length w) - p, p)) |>
  List.unzip |>
  \(leftPads, rightPads) ->
    (List.maximum leftPads ? 0, List.maximum rightPads ? 0) |>
  \(maxLeftPad, maxRightPad) -> (maxLeftPad, maxLeftPad + maxRightPad)

view : Model -> Html.Html Msg
view model =
  Html.table [Html.Attributes.id "crossword"] <| renderCrossword model.structure

renderCrossword : CrosswordStructure -> List (Html.Html Msg)
renderCrossword = List.map renderWord

renderWord crosswordWord =
  Html.tr [Html.Attributes.class "word"] <|
    List.map renderBlock crosswordWord

renderBlock (blockType, letter) =
  Html.td (getBlockClasses blockType |> List.map Html.Attributes.class)
    [Html.text <| Maybe.Extra.unwrap "" String.fromChar letter]

getBlockClasses b = case b of
  Cell -> ["cell"]
  Letter -> ["cell", "letter"]
  Keyword -> ["cell", "letter", "keyword"]
