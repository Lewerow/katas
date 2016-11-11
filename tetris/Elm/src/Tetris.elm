module Tetris exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import Time exposing (Time, millisecond)
import String exposing (fromChar)
import Char exposing (KeyCode, fromCode)
import Matrix exposing (..)
import Keyboard as Keyboard exposing (ups, downs)
import Keyboard.Keys as Keys exposing (arrowUp, arrowDown, arrowLeft, arrowRight)
import Array
import Random

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
type Direction = Down | Left | Right

type GameStatus = NotStarted | Ongoing | Finished
type PauseStatus = Paused | Running
type alias Status = {game: GameStatus, pause: PauseStatus}
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

type alias Stats = {
  points: Int,
  lines: Int,
  level: Int
}

type alias Game = {
  gameBoardState: BoardState,
  hintBoardState: BoardState,
  stats: Stats,
  status: Status
  }

type alias Model = Game

init : (Model, Cmd Msg)
init = (placeBlocks {
  gameBoardState= { size={width=8, height=30},
    id="board", defaultCellClass="cell", cells=repeat 8 30 Free,
    activeBlock={block=OBlock,orientation=E,basePoint={x=4,y=4}}},
  hintBoardState={ size={width=5, height=5},
    id="next-block", defaultCellClass="invisible-cell", cells=repeat 5 5 Free,
    activeBlock={block=ZBlock,orientation=E,basePoint={x=2,y=1}}},
  stats={points=0,lines=0,level=0}, status={game=NotStarted,pause=Running}
  }, Cmd.none)

type Msg = Tick () |
  KeyDown KeyCode |
  KeyUp KeyCode |
  Restart |
  NextBlock (Block, Orientation)

placeBlocks : Game -> Game
placeBlocks g = {g |
  gameBoardState=drawActiveBlock g.gameBoardState,
  hintBoardState=drawActiveBlock g.hintBoardState
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  Tick _ ->
    if model.status.pause == Paused || model.status.game /= Ongoing then (model, Cmd.none)
    else moveActiveBlock Down model
  KeyDown key -> (handleKeyDown key model, Cmd.none)
  KeyUp key -> (model, Cmd.none)
  Restart -> ({model | status={pause=Running, game=Ongoing}}, Cmd.none)
  NextBlock block -> (hintNextBlock model block, Cmd.none)

hintNextBlock : Model -> (Block, Orientation) -> Model
hintNextBlock model newBlock = { model | hintBoardState=setNewBlock model.hintBoardState newBlock }

setNewBlock : BoardState -> (Block, Orientation) -> BoardState
setNewBlock board (b, o) = {board | activeBlock={block=b,orientation=o,basePoint={x=2,y=1}}}

handleKeyDown : KeyCode -> Model -> Model
handleKeyDown key model =
  if key == 80 then
    togglePause model
  else
    moveBlock key model

togglePause : Model -> Model
togglePause m = case m.status.pause of
  Paused ->  {m | status={game=m.status.game, pause=Running}}
  Running -> {m | status={game=m.status.game, pause=Paused}}

moveBlock : KeyCode -> Model -> Model
moveBlock key model = let
  clearedBoard = clearActiveBlock model.gameBoardState
  movedBoard =
    if key == arrowRight.keyCode then moveIfPossible Right clearedBoard
    else if key == arrowLeft.keyCode then moveIfPossible Left clearedBoard
    else Nothing
  in
  { model | gameBoardState = Maybe.withDefault model.gameBoardState movedBoard }

moveActiveBlock : Direction -> Model -> (Model, Cmd Msg)
moveActiveBlock direction model = let
  clearBoard =
    clearActiveBlock model.gameBoardState
  nextGameBoardState =
    moveIfPossible direction clearBoard in
  case nextGameBoardState of
    Just gbs -> ({model | gameBoardState=gbs}, Cmd.none)
    Nothing -> let
      (clearedLines, gameBoard) =
        clearBoard |> drawFixedBlock |> clearFullLines
      (command, newGameBoardState) =
         fetchNextBlock model.hintBoardState gameBoard
      in ({ model | gameBoardState=newGameBoardState,
    stats = appendStats model.stats clearedLines }, command)

appendStats : Stats -> Int -> Stats
appendStats s1 clearedLines = {
  points=s1.points+clearedLines^2,
  lines=s1.lines+clearedLines,
  level=(s1.lines + clearedLines) // 10
  }

clearFullLines : BoardState -> (Int, BoardState)
clearFullLines board = let
  remainingLines = List.filterMap (\x -> getRow x board.cells) [0..(Matrix.height board.cells)] |>
    List.map Array.toList |>
    List.filter (\z -> List.foldl (\x y -> y || (not <| isFixed x)) False z)
  removedLinesCount = board.size.height - List.length remainingLines
  newEmpty = List.repeat removedLinesCount <| List.repeat board.size.width Free
     in
  (removedLinesCount,
    { board | cells = Maybe.withDefault Matrix.empty <|
      Matrix.fromList (List.append newEmpty (remainingLines)) })

moveIfPossible : Direction -> BoardState -> Maybe BoardState
moveIfPossible direction board = if isMovable direction board then
      board |> performMove direction |> drawActiveBlock |> Just
  else
    Nothing

isJust : Maybe a -> Bool
isJust a = case a of
  Just _ -> True
  _ -> False

isFixed : CellContent -> Bool
isFixed b = case b of
  Fixed _ -> True
  _ -> False

isMovable : Direction -> BoardState -> Bool
isMovable direction board =
  getAddresses board.activeBlock |>
  List.map (move direction) |>
  List.map (\p -> get p.x p.y board.cells) |>
  List.foldl (\cell isOk ->
    isOk && (Maybe.withDefault False <| Maybe.map (\x -> not <| isFixed x) cell))
    True

move : Direction -> Point -> Point
move direction addr = case direction of
  Down -> {addr | y=addr.y+1}
  Left -> {addr | x=addr.x+1}
  Right -> {addr | x=addr.x-1}


fetchNextBlock : BoardState -> BoardState -> (Cmd Msg, BoardState)
fetchNextBlock hintBoard gameBoard = let nextBlock=hintBoard.activeBlock in
  (generateNewBlock, {gameBoard | activeBlock=nextBlock})

randomBlock : Random.Generator Int -> Random.Generator Block
randomBlock = Random.map (\n -> case (n % 7)  of
  0 -> IBlock
  1 -> LBlock
  2 -> FBlock
  3 -> HBlock
  4 -> ZBlock
  5 -> SBlock
  6 -> OBlock
  _ -> IBlock) -- to feed the compiler

randomOrientation : Random.Generator Int -> Random.Generator Orientation
randomOrientation = Random.map (\n -> case (n % 4)  of
  0 -> N
  1 -> E
  2 -> S
  3 -> W
  _ -> N) -- to feed the compiler

generateNewBlock : Cmd Msg
generateNewBlock =
  Random.generate NextBlock (Random.pair
    (randomBlock (Random.int 0 6))
    (randomOrientation (Random.int 0 3))
  )

drawFixedBlock : BoardState -> BoardState
drawFixedBlock = draw (\b -> Fixed b)

drawActiveBlock : BoardState -> BoardState
drawActiveBlock = draw (\b -> Moving b)

clearActiveBlock : BoardState -> BoardState
clearActiveBlock = draw (\_ -> Free)

draw : (Block -> CellContent) -> BoardState -> BoardState
draw cellType board = let newCells = markAs cellType board.cells board.activeBlock in
  { board | cells=newCells }

markAs : (Block -> CellContent) -> Matrix CellContent -> BlockRecord -> Matrix CellContent
markAs f m b = List.foldl (\addr m -> set addr.x addr.y (f b.block) m) m (getAddresses b)

getAddresses : BlockRecord -> List Point
getAddresses b = let moveTo base pt = {x=pt.x+base.x, y=pt.y+base.y} in
   List.map (moveTo b.basePoint) (getMask b.block b.orientation)

getMask : Block -> Orientation -> List Point
getMask block orientation = let pt x y = {x=x,y=y} in
  case block of
  OBlock -> [{x=0,y=0},{x=1,y=0},{x=1,y=1},{x=0,y=1}]
  IBlock -> case orientation of
    N -> [{x=0,y=-1},{x=0,y=0},{x=0,y=1},{x=0,y=2}]
    S -> [{x=0,y=-1},{x=0,y=0},{x=0,y=1},{x=0,y=2}]
    E -> [{x=0,y=-1},{x=0,y=0},{x=0,y=1},{x=0,y=2}]
    W -> [{x=-1,y=0},{x=0,y=0},{x=1,y=0},{x=2,y=0}]
  _ -> [pt 0 0, pt 0 1, pt 1 1, pt 1 2]

performMove : Direction -> BoardState -> BoardState
performMove direction board = { board | activeBlock=moveWhole direction board.activeBlock}

moveWhole : Direction -> BlockRecord -> BlockRecord
moveWhole d b = { b | basePoint = move d b.basePoint}

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [
    Time.every (100*millisecond) (\_ -> Tick ()),
    Keyboard.downs KeyDown,
    Keyboard.ups KeyUp
  ]

view : Model -> Html Msg
view model = div [] [ logo, renderGameBoard model]

logo : Html Msg
logo = div [] []

renderGameBoard : Model -> Html Msg
renderGameBoard model = div [ id "game-area" ] [
  div [ id "playground" ] [
    renderMessage model.status,
    renderBoard model.gameBoardState,
    renderGameMenu model
    ]
  ]

renderMessage : Status -> Html Msg
renderMessage status = div [ id "message-container" ] [ status |> getStatusText |> text ]

getStatusText : Status -> String
getStatusText s = case s.game of
  Finished -> "Game over"
  NotStarted -> ""
  _ -> case s.pause of
    Paused -> "Pauza"
    _ -> ""

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
      Fixed b -> [(boardState.defaultCellClass, True),
        ("final", True),
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
  [ button [ id "restart", onClick Restart, disabled <| model.status.game == Ongoing ]
    [ text "Start" ]
  ]

renderStats : Model -> Html Msg
renderStats model = div [ id "stats" ] [
  renderItemContainer "points" "Punkty: " model.stats.points,
  renderItemContainer "lines" "Linie: " model.stats.lines,
  renderItemContainer "level" "Poziom: " model.stats.level
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
