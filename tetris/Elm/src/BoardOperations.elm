module BoardOperations exposing (..)

import Block exposing (..)
import BlockData exposing (getMask)
import Board exposing (..)
import Messages exposing (..)

import Array
import Random
import Char exposing (KeyCode)
import Matrix exposing (..)
import Keyboard.Keys as Keys exposing (arrowUp, arrowDown, arrowLeft, arrowRight)

type Direction = Down | Left | Right


fixBlock : BoardState -> (Int, BoardState)
fixBlock board = board |> clearActiveBlock |> drawFixedBlock |> clearFullLines

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

performMove : Direction -> BoardState -> BoardState
performMove direction board = { board | activeBlock=moveWhole direction board.activeBlock}

moveWhole : Direction -> BlockRecord -> BlockRecord
moveWhole d b = { b | basePoint = move d b.basePoint}

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

-- precondition: block is movable
moveBlockInDirection : Direction -> BoardState -> BoardState
moveBlockInDirection direction board =
  board |> clearActiveBlock |> performMove direction |> drawActiveBlock

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
  (generateNewBlock NextBlock, {gameBoard | activeBlock={
    block=nextBlock.block,
    orientation=nextBlock.orientation,
    basePoint=calculateBasePoint gameBoard nextBlock} })

calculateBasePoint : BoardState -> BlockRecord -> Point
calculateBasePoint board block =
  { block | basePoint={x=0,y=0}} |> getAddresses |>
    List.foldl (\p acc -> {x=Basics.min acc.x p.x, y = Basics.min acc.y p.y}) { x=0,y=0 }|>
    \{x,y} -> { x=board.size.width // 2, y = -y }

generateNewBlock : ((Block, Orientation) -> Msg) -> Cmd Msg
generateNewBlock msgCreator =
  Random.generate msgCreator (Random.pair
    (randomBlock (Random.int 0 6))
    (randomOrientation (Random.int 0 3))
  )

moveIfPossible : Direction -> BoardState -> Maybe BoardState
moveIfPossible d b =
  if isMovable d b then Just <| moveBlockInDirection d b else Nothing

moveBlock : KeyCode -> BoardState -> BoardState
moveBlock key board = let
  movedBoard =
    if key == arrowRight.keyCode then moveIfPossible Right board
    else if key == arrowLeft.keyCode then moveIfPossible Left board
    else if key == arrowUp.keyCode then rotate board
    else Nothing
  in
  Maybe.withDefault board movedBoard

rotate : BoardState -> Maybe BoardState
rotate board = if canBeRotated board.activeBlock board then
    board |> clearActiveBlock |>
      \b -> { b | activeBlock = rotateBlock b.activeBlock  } |>
      drawActiveBlock  |> Just
  else
    Nothing

canBeRotated : BlockRecord -> BoardState -> Bool
canBeRotated block board = rotateBlock block |> getAddresses |>
  List.map (\p -> get p.x p.y board.cells) |>
  List.foldl (\cell isOk ->
    isOk && (Maybe.withDefault False <| Maybe.map (\x -> not <| isFixed x) cell))
    True

rotateBlock : BlockRecord -> BlockRecord
rotateBlock block = { block | orientation=BlockData.nextOrientation block.orientation }

hintNextBlock : BoardState -> (Block, Orientation) -> BoardState
hintNextBlock board newBlock =
  board |> clearActiveBlock |> setNewBlock newBlock |> drawActiveBlock

setNewBlock : (Block, Orientation) -> BoardState -> BoardState
setNewBlock (b, o) board =
  {board | activeBlock={block=b,orientation=o,basePoint={x=2,y=1}}}
