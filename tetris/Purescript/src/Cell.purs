module Cell where

import Halogen.HTML as H
import Block (BlockType, getClassName)
import Data.Maybe (Maybe(Just))

getClasses :: Maybe BlockType -> Array H.ClassName
getClasses (Just blockType) = [ fixedCellClass, getClassName blockType ]
getClasses _ = [ emptyCellClass ]

emptyCellClass :: H.ClassName
emptyCellClass = H.className "cell"

fixedCellClass :: H.ClassName
fixedCellClass = H.className "final cell"
