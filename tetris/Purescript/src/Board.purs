module Board where

import Matrix as Matrix
import Data.Array as Array
import Prelude (($), map)

import Halogen.HTML as H
import Halogen.HTML.Properties as P

import Cell as Cell

data Board = Board {
  cells :: Matrix.Matrix Cell.CellType
}

rowClass :: H.ClassName
rowClass = H.className "row"

render :: forall a p i. String -> Board -> a -> H.HTML p i
render divId (Board { cells }) _ = H.div [ P.id_ divId ]
  $ map (\y -> H.div [ P.class_ rowClass ]
    $ map (\x -> H.div [ P.class_ $ Cell.getClass $ Matrix.get x y cells] [])
    $ Array.range 1 (Matrix.width cells))
  $ Array.range 1 (Matrix.height cells)
