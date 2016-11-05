define(["./Cell"], function(Cell) {
  
  function isInClosedOpenInterval(min, val, max) {
    return val >= min && val < max;
  }
  
  function Board(width, height, cellClass, defaultValue) {
    this._width = width;
    this._height = height;
    this._cellClass = cellClass;
    this._defaultCellValue = defaultValue
  }
  
  Board.prototype.draw = function(parent) {
    var i, j;
		var row, cell;
		var cells = [];
		for(i = 0; i < this._height; ++i) {
			cells.push([]);
			row = document.createElement("div");
			row.className = "row";
			for(j = 0; j < this._width; ++j) {
				cell = document.createElement("div");
				row.appendChild(cell);
        cells[i].push(new Cell(this._cellClass, this._defaultCellValue, cell))
			}
			parent.appendChild(row);
		}
		
		return cells;
  }
    
  Board.isValidBlock = function(board, block, basePoint) {
    return block.points(basePoint).reduce((acc, b) => acc && 
      isInClosedOpenInterval(0, b.x, board[0].length) && 
      isInClosedOpenInterval(0, b.y, board.length) &&
      board[b.y][b.x].currentValue !== 'x', 
    true);
  }
  
  return Board;
});