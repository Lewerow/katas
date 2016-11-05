define(["./Board", "./BlockGenerator"], function(Board, BlockGenerator) {
  function Game(board, hintBox) {
    this._board = board;
    this._hintBox = hintBox;
  }
  
  function getStartPoint(block, board) {
    return [4,4];
  }
  
  function pullDown(board, toMoveUp) {
    var i;
    for(i = toMoveUp; i > 0; --i) {
      board[i].forEach((v, k) => Cell.swap(board[i][k], board[i-1][k]));
    }
  }
  
  function emptify(row) {
    row.forEach(c => c.reset());
  }
  
  function speedUp() {
    normalRound -= fastRound;
    if(normalRound < fastRound)
      normalRound = fastRound;
  }
  
  function levelUp() {
    level++;
  	elemById("level").innerHTML = level;
    speedUp();
  }
  
  function awardPoints(howManyLines) {
    if(clearedLines % 10 + howManyLines > 10) {
      levelUp();
    }
    
    clearedLines += howManyLines;
    points += Math.pow(howManyLines, 2);
  	elemById("points").innerHTML = points;
  }
  
  Game.prototype.clearFullLines = function() {
    const fullRows = this._board.map((row) => {
      return row.reduce((acc, c) => acc && c.currentValue === 'x', true);
    });
    
    const clearedRowCount = fullRows.reduce((a,b) => a + b, 0);
    awardPoints(clearedRowCount);
    fullRows.forEach((fullRow, k) => {
      if(fullRow) {
        emptify(this._board[k]);
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
    clearFullLines(board);
    return false;
  }

  Game.prototype.rotateBlock = function() {
    if(this._currentBlock.canRotate(this._basePoint, this._board)) {
      this._currentBlock.wrappedInRedraw(this._basePoint, this._board, () => this._currentBlock.rotate());
      return true;
    }
    return false;
  }
  
  Game.prototype.nextBlock = function() {
    this._currentBlock = this.nextBlock();
    this._nextBlock.wrappedInRedraw(() => Object.assign(this._nextBlock, BlockGenerator.getBlock()));
    this._basePoint = getStartPoint(this._currentBlock, this._board);
    
    this._currentBlock.draw(this._basePoint, this._board);
    return Board.isValidBlock(this._board, this._currentBlock, this._basePoint);
  }
  
  Game.prototype.start = function() {
    return this.nextBlock();
    this._currentBlock = BlockGenerator.getBlock();
    this._nextBlock = BlockGenerator.getBlock();
    this._basePoint = getStartPoint(this._currentBlock, this._board);
    
    this._nextBlock.draw([2,1], this._hintBox);
    this._currentBlock.draw(this._basePoint, this._board);    
  }
  
  Game.prototype.over = function() {
    elemById("game-menu").innerHTML = "GAME OVER!";    
  }
  
  return Game;
})