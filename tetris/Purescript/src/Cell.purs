module Cell where

import Data.Maybe (Maybe(Just))
import Halogen.HTML as H

data CellType = Free | Fixed

getClass :: Maybe CellType -> H.ClassName
getClass (Just Fixed) = fixedCellClass
getClass _ = emptyCellClass

emptyCellClass :: H.ClassName
emptyCellClass = H.className "cell"

fixedCellClass :: H.ClassName
fixedCellClass = H.className "final cell"
