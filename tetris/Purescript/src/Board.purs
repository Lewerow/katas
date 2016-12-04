module Board where

import Data.Array as Array
import Matrix as Matrix
import DOM.HTML.HTMLTableRowElement (cells)
import Data.Array (all, foldl)
import Data.Maybe (fromMaybe, isNothing, Maybe(..))
import Prelude (($), (-), (==), (<>), map, bind, pure)

import Halogen.HTML as H
import Halogen.HTML.Properties as P

import Cell as Cell
import Block as Block

data Board = Board {
  cells :: Matrix.Matrix (Maybe Block.BlockType)
}

rowClass :: H.ClassName
rowClass = H.className "row"

getClasses :: Int -> Int -> Matrix.Matrix (Maybe Block.BlockType) -> Block.Block -> Array H.ClassName
getClasses x y cells block = fromMaybe [] $ do
  cellContent <- Matrix.get x y cells
  pure $ (Cell.getClasses cellContent <> Block.getClasses x y block)

render :: forall p i. String -> Board -> Block.Block -> H.HTML p i
render divId (Board { cells }) block = H.div [ P.id_ divId ]
  $ map (\y -> H.div [ P.class_ rowClass ]
    $ map (\x -> H.div [ P.classes $ getClasses x y cells block ] [])
    $ Array.range 0 (Matrix.width cells - 1))
  $ Array.range 0 (Matrix.height cells - 1)

fitsIn :: Block.Block -> Board -> Boolean
fitsIn block (Board { cells }) = let positions = Block.usedPositions block in
  all areNotConflicting positions
  where
    areNotConflicting { x, y } = fromMaybe false $ do
      cell <- Matrix.get x y cells
      pure $ isNothing cell

fix :: Block.Block -> Board -> Board
fix block@(Block.Block { blockType }) (Board { cells }) = let
  positions = Block.usedPositions block in
    Board { cells: foldl fixPosition cells positions }
    where
      fixPosition cells { x, y } =
        fromMaybe Matrix.empty $ Matrix.set x y (Just blockType) cells
