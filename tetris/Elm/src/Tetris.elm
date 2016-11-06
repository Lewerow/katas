module Tetris exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Time exposing (Time, millisecond)
import String exposing (fromChar)
import Char exposing (KeyCode, fromCode)
import Matrix exposing (..)

main: Program Never
main = App.program {
  init = init,
  view = view,
  update = update,
  subscriptions = subscriptions
  }

type Block = IBlock | LBlock | FBlock | HBlock | ZBlock | SBlock | OBlock
type Orientation = N | E | S | W

type alias Point = {
  x: Int,
  y: Int
}

type alias BoardSize = {
  width: Int,
  height: Int
}

type CellContent = Free | Moving Block | Fixed Block

type alias ClassName = String
type alias RowId = Int
type alias ColumnId = Int
type alias CellId = (RowId, ColumnId)
type alias BoardId = String
type alias BlockRecord = {
  block: Block,
  orientation: Orientation,
  basePoint: Point
}
type alias BoardState = {
  size: BoardSize,
  id: BoardId,
  defaultCellClass: ClassName,
  cells: Matrix CellContent,
  activeBlock: BlockRecord
}

type alias Game = {
  gameBoardState: BoardState,
  hintBoardState: BoardState
  }

type alias Model = Game

init : (Model, Cmd Msg)
init = ({
  gameBoardState= { size={width=15, height=30},
    id="board", defaultCellClass="cell", cells=repeat 15 30 Free,
    activeBlock={block=OBlock,orientation=E,basePoint={x=4,y=4}}},
  hintBoardState={ size={width=5, height=5},
    id="next-block", defaultCellClass="invisible-cell", cells=repeat 5 5 Free,
    activeBlock={block=OBlock,orientation=E,basePoint={x=4,y=4}}}
  }, Cmd.none)

type Msg = Tick ()

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = (moveActiveBlock model, Cmd.none)

moveActiveBlock: Model -> Model
moveActiveBlock model = {model | gameBoardState=oneDown model.gameBoardState}

oneDown : BoardState -> BoardState
oneDown board = clearActiveBlock board |> moveActiveBlockDown |> drawActiveBlock

drawActiveBlock : BoardState -> BoardState
drawActiveBlock board = let newCells = markAs (\b -> Moving b) board.cells board.activeBlock in
  { board | cells=newCells }

clearActiveBlock : BoardState -> BoardState
clearActiveBlock board = let newCells = markAs (\_ -> Free) board.cells board.activeBlock in
  { board | cells=newCells }

markAs : (Block -> CellContent) -> Matrix CellContent -> BlockRecord -> Matrix CellContent
markAs f m b = List.foldl (\addr m -> set addr.x addr.y (f b.block) m) m (getAddresses b)

getAddresses : BlockRecord -> List Point
getAddresses b = let moveTo base pt = {x=pt.x+base.x, y=pt.y+base.y} in
   List.map (moveTo b.basePoint) (getMask b.block b.orientation)

getMask : Block -> Orientation -> List Point
getMask block orientation = [{x=0,y=0},{x=1,y=0},{x=1,y=1},{x=0,y=1}]

moveActiveBlockDown : BoardState -> BoardState
moveActiveBlockDown board = { board | activeBlock=moveDown board.activeBlock}

moveDown : BlockRecord -> BlockRecord
moveDown b = { b | basePoint = {x=b.basePoint.x, y=b.basePoint.y+1}}

subscriptions : Model -> Sub Msg
subscriptions model = Time.every (500*millisecond) (\_ -> Tick ())

view : Model -> Html Msg
view model = div [] [ logo, renderGameBoard model]

logo : Html Msg
logo = div [] []

renderGameBoard : Model -> Html Msg
renderGameBoard model = div [ id "game-area" ] [
  div [ id "playground" ] [
    renderBoard model.gameBoardState,
    renderGameMenu model
    ]
  ]

renderBoard : BoardState -> Html Msg
renderBoard boardState = div [ id boardState.id ]
  <| List.map (renderRow boardState) [0..boardState.size.height-1]

renderRow : BoardState -> RowId -> Html Msg
renderRow boardState rowId = div [ class "row" ]
  <| List.map (\colId -> renderCell boardState rowId colId) [0..boardState.size.width-1]

renderCell : BoardState -> RowId -> ColumnId -> Html Msg
renderCell boardState rowId columnId =
  div [ getClasses boardState rowId columnId |> classList ] []

getClasses : BoardState -> RowId -> ColumnId -> List (String, Bool)
getClasses boardState rowId columnId =
  case get columnId rowId boardState.cells of
    Nothing -> [("error", True), (boardState.defaultCellClass, True)]
    Just cellState -> case cellState of
      Free -> [(boardState.defaultCellClass, True)]
      Moving b -> [(boardState.defaultCellClass, True),
        ("block", True),
        (getBlockClass b,True)]
      Fixed b -> [("fixed", True),
        ("block", True),
        (getBlockClass b,True)]

getBlockClass : Block -> ClassName
getBlockClass b = case b of
  IBlock -> "I-block"
  LBlock -> "L-block"
  FBlock -> "F-block"
  HBlock -> "H-block"
  ZBlock -> "Z-block"
  SBlock -> "S-block"
  OBlock -> "O-block"


renderGameMenu : Model -> Html Msg
renderGameMenu model = div [ id "game-menu" ] [
  renderMetadata model,
  renderHelp model
  ]

renderMetadata : Model -> Html Msg
renderMetadata model = div [ id "metadata" ] [
  renderNextBlock model,
  renderRestartButton model,
  renderStats model
 ]

renderNextBlock : Model -> Html Msg
renderNextBlock model = renderBoard model.hintBoardState

renderRestartButton : Model -> Html Msg
renderRestartButton model = div [ id "restart-container" ]
  [ button [ id "restart" ] [ text "Start" ] ]

renderStats : Model -> Html Msg
renderStats model = div [ id "stats" ] [
  renderItemContainer "points" "Punkty: " 0,
  renderItemContainer "lines" "Linie: " 0,
  renderItemContainer "level" "Poziom" 1
  ]

renderItemContainer : String -> String -> Int -> Html Msg
renderItemContainer containee textVal value = div
  [ id (containee ++ "-container")]
  [ text textVal, span [ id containee ] [ value |> toString |> text ] ]

renderHelp : Model -> Html Msg
renderHelp model = div [ id "help" ] [
  h4 [] [text "Sterowanie: ",
    ul [ id "help-items"] [
        li [class "help-item"] [ text <| "p " ++ (asString 8212) ++ " pauza"],
        li [class "help-item"] [ text <| (asString 8594)++ " " ++ (asString 8212)
          ++ " przesunięcie bloku w prawo"],
        li [class "help-item"] [ text <| (asString 8596) ++ " " ++ (asString 8212)
          ++ " przesunięcie bloku w lewo"],
        li [class "help-item"] [ text <|  (asString 8593) ++ " "
          ++ (asString 8212) ++ " obrót bloku o 90" ++ (asString 176)
          ++ " w prawo"],
        li [class "help-item"] [ text <| (asString 8595) ++ " "
          ++ (asString 8212) ++ " przyspiesza spadanie bloku"]
      ]
    ]
  ]

asString : KeyCode -> String
asString key = key |> Char.fromCode |> String.fromChar
