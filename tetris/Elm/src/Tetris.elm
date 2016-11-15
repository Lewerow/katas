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

import Task
import Process

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
  level: Int,
  stepDelay: Time
}

type alias Game = {
  gameBoardState: BoardState,
  hintBoardState: BoardState,
  stats: Stats,
  status: Status,
  fastModeOn: Bool
  }

type alias Model = Game

initialModel : Model
initialModel = {
  gameBoardState= { size={width=15, height=30},
    id="board", defaultCellClass="cell", cells=repeat 15 30 Free,
    activeBlock={block=OBlock,orientation=E,basePoint={x=7,y=0}}},
  hintBoardState={ size={width=5, height=5},
    id="next-block", defaultCellClass="invisible-cell", cells=repeat 5 5 Free,
    activeBlock={block=ZBlock,orientation=E,basePoint={x=2,y=1}}},
  stats={points=0,lines=0,level=0,stepDelay=400 * Time.millisecond },
  status={game=NotStarted,pause=Running}, fastModeOn=False
  }

init : (Model, Cmd Msg)
init = (initialModel, Cmd.none)

type Msg = TickMove |
  KeyDown KeyCode |
  KeyUp KeyCode |
  Restart |
  NextBlock (Block, Orientation)

placeBlocks : Game -> Game
placeBlocks g = {g |
  gameBoardState=drawActiveBlock g.gameBoardState,
  hintBoardState=drawActiveBlock g.hintBoardState
  }

delayMessage : Msg -> Time -> Cmd Msg
delayMessage msg time = let f = \_ -> msg in
  Task.perform f f (Process.sleep time)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  TickMove ->
    if model.status.game == Finished then (model, Cmd.none)
    else if model.status.pause == Paused  then (model, delayMessage TickMove (getDelay model))
    else let (newModel, baseCmd) = moveActiveBlock Down model in
      (newModel, Cmd.batch [ baseCmd, delayMessage TickMove (getDelay newModel) ])
  KeyDown key -> (handleKeyDown key model, Cmd.none)
  KeyUp key -> ( if key == arrowDown.keyCode then { model | fastModeOn=False} else model, Cmd.none)
  Restart -> let
    (commands, gameBoard) = fetchNextBlock initialModel.hintBoardState initialModel.gameBoardState in
    ({initialModel | status={pause=Running, game=Ongoing}}, Cmd.batch [delayMessage TickMove (getDelay initialModel), commands])
  NextBlock block -> (hintNextBlock model block, Cmd.none)

getDelay : Model -> Time
getDelay model = if model.fastModeOn then minStep else model.stats.stepDelay

rotate : BoardState -> Maybe BoardState
rotate board = if canBeRotated board.activeBlock board then
    Just <| drawActiveBlock { board | activeBlock = rotateBlock board.activeBlock  }
  else
    Nothing

canBeRotated : BlockRecord -> BoardState -> Bool
canBeRotated block board = rotateBlock block |> getAddresses |>
  List.map (\p -> get p.x p.y board.cells) |>
  List.foldl (\cell isOk ->
    isOk && (Maybe.withDefault False <| Maybe.map (\x -> not <| isFixed x) cell))
    True

rotateBlock : BlockRecord -> BlockRecord
rotateBlock block = let
  newOrientation = case block.orientation of
  W -> S
  N -> W
  E -> N
  S -> E in
  { block | orientation = newOrientation }

hintNextBlock : Model -> (Block, Orientation) -> Model
hintNextBlock model newBlock = { model | hintBoardState=
  (model.hintBoardState |> clearActiveBlock |> setNewBlock newBlock |> drawActiveBlock)
  }

setNewBlock : (Block, Orientation) -> BoardState -> BoardState
setNewBlock (b, o) board =
  {board | activeBlock={block=b,orientation=o,basePoint={x=2,y=1}}}

handleKeyDown : KeyCode -> Model -> Model
handleKeyDown key model =
  if key == 80 then
    togglePause model
  else if key == arrowDown.keyCode then
    { model | fastModeOn=True}
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
    else if key == arrowUp.keyCode then rotate clearedBoard
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
      in
    if isValidActiveBlock newGameBoardState.activeBlock newGameBoardState.cells then
      ({ model | gameBoardState=newGameBoardState,
        stats = appendStats model.stats clearedLines }, command)
    else ({
      model | gameBoardState=newGameBoardState,
        stats = appendStats model.stats clearedLines,
        status = { pause= model.status.pause, game=Finished }
    }, command)

appendStats : Stats -> Int -> Stats
appendStats s1 clearedLines = let
  newLevel = (s1.lines + clearedLines) // maxLevel in
  {
  points=s1.points+clearedLines^2,
  lines=s1.lines+clearedLines,
  level= newLevel,
  stepDelay= if newLevel /= s1.level then calcDelay s1.stepDelay newLevel else s1.stepDelay
  }

minStep : Time
minStep = 25 * Time.millisecond

maxLevel : Int
maxLevel = 10

calcDelay : Time -> Int -> Time
calcDelay step level =
  if level > maxLevel then 3 * minStep
  else  step * ((3*minStep / step) ^ (1.0 / (toFloat (maxLevel - level + 1))))

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

isValidActiveBlock : BlockRecord -> Matrix CellContent -> Bool
isValidActiveBlock block cells =
  getAddresses block |>
  List.map (\p -> get p.x p.y cells) |>
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
  (generateNewBlock, {gameBoard | activeBlock={
    block=nextBlock.block,
    orientation=nextBlock.orientation,
    basePoint=calculateBasePoint gameBoard nextBlock} })

calculateBasePoint : BoardState -> BlockRecord -> Point
calculateBasePoint board block =
  { block | basePoint={x=0,y=0}} |> getAddresses |>
    List.foldl (\p acc -> {x=Basics.min acc.x p.x, y = Basics.min acc.y p.y}) { x=0,y=0 }|>
    \{x,y} -> { x=board.size.width // 2, y = -y }

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
  IBlock -> let
    vertical = [pt -1 0, pt 0 0, pt 1 0, pt 2 0]
    horizontal = [pt 0 -1, pt 0 0, pt 0 1, pt 0 2] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  LBlock -> case orientation of
    N -> [pt 0 0, pt -1 0, pt -1 1, pt -1 2]
    E -> [pt -2 0, pt -2 1, pt -1 1, pt 0 1]
    S -> [pt 0 0, pt 0 1, pt 0 2, pt -1 2]
    W -> [pt -2 0, pt -1 0, pt 0 0, pt 0 1]
  FBlock -> case orientation of
    N -> [pt -1 0, pt 0 0, pt 0 1, pt 0 2]
    E -> [pt 0 0, pt -1 0, pt -2 0, pt -2 1]
    S -> [pt -1 0, pt -1 1, pt -1 2, pt 0 2]
    W -> [pt 0 0, pt 0 1, pt -1 1, pt -2 1]
  HBlock -> case orientation of
    N -> [pt -1 0, pt 0 0, pt 1 0, pt 0 1]
    E -> [pt 0 -1, pt 0 0, pt 0 1, pt 1 0]
    S -> [pt -1 0, pt 0 0, pt 1 0, pt 0 -1]
    W -> [pt 0 -1, pt 0 0, pt 0 1, pt -1 0]
  ZBlock -> let
    vertical = [pt 0 0, pt 0 1, pt 1 1, pt 1 2]
    horizontal = [pt 1 0, pt 0 0, pt 0 1, pt -1 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  SBlock -> let
    vertical = [pt 1 0, pt 1 1, pt 0 1, pt 0 2]
    horizontal = [pt -1 0, pt 0 0, pt 0 1, pt 1 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal


performMove : Direction -> BoardState -> BoardState
performMove direction board = { board | activeBlock=moveWhole direction board.activeBlock}

moveWhole : Direction -> BlockRecord -> BlockRecord
moveWhole d b = { b | basePoint = move d b.basePoint}

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [
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
