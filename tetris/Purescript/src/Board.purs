module Board where

import Matrix as Matrix
import Data.Array as Array
import Prelude (($), (-), map)

import Halogen.HTML as H
import Halogen.HTML.Properties as P

import Cell as Cell
import Block as Block

data Board = Board {
  cells :: Matrix.Matrix Cell.CellType
}

rowClass :: H.ClassName
rowClass = H.className "row"

getClasses :: Int -> Int -> Matrix.Matrix Cell.CellType -> Block.Block -> Array H.ClassName
getClasses x y cells block =
  (Cell.getClass $ Matrix.get x y cells) `Array.cons` Block.getClasses x y block

render :: forall p i. String -> Board -> Block.Block -> H.HTML p i
render divId (Board { cells }) block = H.div [ P.id_ divId ]
  $ map (\y -> H.div [ P.class_ rowClass ]
    $ map (\x -> H.div [ P.classes $ getClasses x y cells block ] [])
    $ Array.range 0 (Matrix.width cells - 1))
  $ Array.range 0 (Matrix.height cells - 1)
