define(["./Cell", "./Board", "./BlockGenerator"], function(Cell, Board, BlockGenerator) {
  const defaultFastRoundDelay = 25;
  const defaultNormalRoundDelay = 400;
  const levelCount = 3;
  const linesPerLevel = 1;
  function Game(board, hintBox) {
    this._board = board;
    this._hintBox = hintBox;
    this._clearedLines = 0;
    this._level = 1;
    this._points = 0;
    this._normalRoundDelay = defaultNormalRoundDelay;
  	document.getElementById("points").innerHTML = this._points;
  	document.getElementById("level").innerHTML = this._level;
  	document.getElementById("lines").innerHTML = this._clearedLines;
  }
  
  function pullDown(board, toMoveUp) {
    var i;
    for(i = toMoveUp; i > 0; --i) {
      board[i].forEach((v, k) => Cell.swap(board[i][k], board[i-1][k]));
    }
  }
  
  Game.prototype.speedUp = function() {
    if(this._level > levelCount) {
      return;
    }
    
    this._normalRoundDelay *= Math.pow((3 * defaultFastRoundDelay) / this._normalRoundDelay, 
      1 / (levelCount - this._level + 1));
  }
  
  Game.prototype.getFastRoundDelay = function() {
    return defaultFastRoundDelay;
  }
  
  Game.prototype.getNormalRoundDelay = function() {
    return this._normalRoundDelay;
  }
  
  Game.prototype.levelUp = function() {
    this._level++;
  	document.getElementById("level").innerHTML = this._level;
    this.speedUp();
  }
  
  Game.prototype.awardPoints = function(howManyLines) {
    if(this._clearedLines % linesPerLevel + howManyLines >= linesPerLevel) {
      this.levelUp();
    }
    
    this._clearedLines += howManyLines;
  	document.getElementById("lines").innerHTML = this._clearedLines;
    this._points += Math.pow(howManyLines, 2);
  	document.getElementById("points").innerHTML = this._points;
  }
  
  Game.prototype.clearFullLines = function() {
    const fullRows = this._board.map((row) => {
      return row.reduce((acc, c) => acc && c.currentValue === 'x', true);
    });
    
    const clearedRowCount = fullRows.filter((a) => a).length;
    this.awardPoints(clearedRowCount);
    fullRows.forEach((fullRow, k) => {
      if(fullRow) {
        this._board[k].forEach(c => c.reset());
        pullDown(this._board, k);
      }
    });
  }
  Game.prototype.moveBlockLeft = function() {
    if(Board.isValidBlock(this._board, this._currentBlock, [this._basePoint[0], this._basePoint[1] - 1])) {
      this._currentBlock.wrappedInRedraw(this._basePoint, this._board, () => this._basePoint[1]--);
      return true;
    }
    return false;
  }
  
  Game.prototype.moveBlockRight = function() {
    if(Board.isValidBlock(this._board, this._currentBlock, [this._basePoint[0], this._basePoint[1] + 1])) {
      this._currentBlock.wrappedInRedraw(this._basePoint, this._board, () => this._basePoint[1]++);
      return true;
    }
    return false;
  }
  
  Game.prototype.moveBlockDown = function() {
    if(Board.isValidBlock(this._board, this._currentBlock, [this._basePoint[0] + 1, this._basePoint[1]])) {
      this._currentBlock.wrappedInRedraw(this._basePoint, this._board, () => this._basePoint[0]++);
      return true;
    }
    
    this._currentBlock.fasten(this._basePoint, this._board);
    this.clearFullLines(this._board);
    return this.addNextBlock()
  }

  Game.prototype.rotateBlock = function() {
    if(this._currentBlock.canRotate(this._basePoint, this._board)) {
      this._currentBlock.wrappedInRedraw(this._basePoint, this._board, () => this._currentBlock.rotate());
      return true;
    }
    return false;
  }
  
  Game.prototype.addNextBlock = function() {
    this._currentBlock = this._nextBlock;
    this._basePoint = Board.getStartPoint(this._board, this._currentBlock);
    
    this._nextBlock.erase([2,1], this._hintBox);
    this._nextBlock = BlockGenerator.getBlock();
    this._nextBlock.draw([2,1], this._hintBox);
    
    if(Board.isValidBlock(this._board, this._currentBlock, this._basePoint)) {
      this._currentBlock.draw(this._basePoint, this._board);
      return true;      
    }
    return false;
  }
  
  Game.prototype.start = function() {
    this._nextBlock = BlockGenerator.getBlock();
    this.addNextBlock();
  }
  
  Game.prototype.over = function() {
    document.getElementById("message").innerHTML = "Game over!";
    document.getElementById("restart").disabled = false;
    document.getElementById("restart").innerHTML = "Restart";
  }
  
  return Game;
})