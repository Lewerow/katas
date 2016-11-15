module Block exposing (Block(..), Orientation(..), Point, randomBlock, randomOrientation)

import Random

type Block = IBlock | LBlock | FBlock | HBlock | ZBlock | SBlock | OBlock
type Orientation = N | E | S | W

type alias Point = {
  x: Int,
  y: Int
}

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
