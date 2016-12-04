module Block where

import Data.Array (findIndex)
import Data.Maybe (isJust)
import Halogen.HTML (ClassName, className)
import Prelude (($), (>), (+), (==), (&&), negate, mod, map)

data BlockType = IBlock | LBlock | FBlock | HBlock | ZBlock | SBlock | OBlock
data Orientation = N | E | S | W

data Block = Block {
  blockType :: BlockType,
  orientation :: Orientation,
  position :: { x :: Int, y :: Int }
}

moveDown :: Block -> Block
moveDown (Block block) = Block (block { position = (block.position { y = block.position.y + 1 } ) })

getClasses :: Int -> Int -> Block -> Array ClassName
getClasses x y block@(Block { blockType }) =
  if isCovered x y block then [ getClassName blockType, className "block" ]
  else []

getClassName :: BlockType -> ClassName
getClassName t = case t of
 IBlock -> className "I-block"
 LBlock -> className "L-block"
 FBlock -> className "F-block"
 HBlock -> className "H-block"
 ZBlock -> className "Z-block"
 SBlock -> className "S-block"
 OBlock -> className "O-block"

abs :: Int -> Int
abs i = if i > 0 then i else -i

getBlock :: Int -> BlockType
getBlock i = case abs i of
 0 -> IBlock
 1 -> LBlock
 2 -> FBlock
 3 -> HBlock
 4 -> ZBlock
 5 -> SBlock
 _ -> OBlock

getOrientation :: Int -> Orientation
getOrientation i = case abs i of
 0 -> N
 1 -> E
 2 -> S
 _ -> W

isCovered :: Int -> Int -> Block -> Boolean
isCovered x0 y0 block =
  isJust $ findIndex (\{ x, y } -> x == x0 && y == y0) $ usedPositions block

usedPositions :: Block -> Array { x ::Int, y :: Int }
usedPositions (Block { blockType, orientation, position }) =
  map ( \{ x, y } -> { x: x + position.x, y: y + position.y } ) $
    getMask blockType orientation

arbitraryBlock :: Int -> Block
arbitraryBlock i = Block {
  blockType: getBlock $ i `mod` 7
  , orientation: getOrientation $ i `mod` 4
  , position: { x: 2
    , y: 1
  }
}

getMask :: BlockType -> Orientation -> Array { x :: Int, y :: Int }
getMask block orientation = let pt x y = { x: x, y: y } in
  case block of
  OBlock -> [pt 0 0, pt 1 0, pt 1 1, pt 0 1]
  IBlock -> let
    vertical = [pt (-1) 0, pt 0 0, pt 1 0, pt 2 0]
    horizontal = [pt 0 (-1), pt 0 0, pt 0 1, pt 0 2] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  LBlock -> case orientation of
    N -> [pt 0 0, pt (-1) 0, pt (-1) 1, pt (-1) 2]
    E -> [pt (-2) 0, pt (-2) 1, pt (-1) 1, pt 0 1]
    S -> [pt 0 0, pt 0 1, pt 0 2, pt (-1) 2]
    W -> [pt (-2) 0, pt (-1) 0, pt 0 0, pt 0 1]
  FBlock -> case orientation of
    N -> [pt (-1) 0, pt 0 0, pt 0 1, pt 0 2]
    E -> [pt 0 0, pt (-1) 0, pt (-2) 0, pt (-2) 1]
    S -> [pt (-1) 0, pt (-1) 1, pt (-1) 2, pt 0 2]
    W -> [pt 0 0, pt 0 1, pt (-1) 1, pt (-2) 1]
  HBlock -> case orientation of
    N -> [pt (-1) 0, pt 0 0, pt 1 0, pt 0 1]
    E -> [pt 0 (-1), pt 0 0, pt 0 1, pt 1 0]
    S -> [pt (-1) 0, pt 0 0, pt 1 0, pt 0 (-1)]
    W -> [pt 0 (-1), pt 0 0, pt 0 1, pt (-1) 0]
  ZBlock -> let
    vertical = [pt 0 0, pt 0 1, pt 1 1, pt 1 2]
    horizontal = [pt 1 0, pt 0 0, pt 0 1, pt (-1) 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  SBlock -> let
    vertical = [pt 1 0, pt 1 1, pt 0 1, pt 0 2]
    horizontal = [pt (-1) 0, pt 0 0, pt 0 1, pt 1 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
