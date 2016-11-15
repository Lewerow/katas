module Board exposing (..)

import Block exposing (Block, Orientation, Point)
import Matrix exposing (Matrix)

type CellContent = Free | Moving Block | Fixed Block
type alias RowId = Int
type alias ColumnId = Int
type alias CellId = (RowId, ColumnId)
type alias BoardId = String
type alias ClassName = String

type alias BlockRecord = {
  block: Block,
  orientation: Orientation,
  basePoint: Point
}

type alias BoardSize = {
  width: Int,
  height: Int
}

type alias BoardState = {
  size: BoardSize,
  id: BoardId,
  defaultCellClass: ClassName,
  cells: Matrix CellContent,
  activeBlock: BlockRecord
}
