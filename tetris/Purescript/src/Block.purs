module Block where

data BlockType = IBlock | LBlock | FBlock | HBlock | ZBlock | SBlock | OBlock
data Orientation = N | E | S | W

data Block = Block {
  type :: BlockType,
  orientation :: Orientation,
  position :: { x :: Int, y :: Int }
}
