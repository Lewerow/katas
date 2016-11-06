define(["./Board.js"], function(Board) {
  function Block(symbol, versions) {
    this._symbol = symbol;
    this._versions = versions;
    this._currentVersion = 0;
  }
  
  Block.prototype.clone = function() {
    var newBlock = new Block(this._symbol, this._versions);
    newBlock._currentVersion = this._currentVersion;
    return newBlock;
  }
  
  Block.prototype.canRotate = function(basePoint, board) {
    return Board.isValidBlock(board, this.rotated(), basePoint);
  }
  
  Block.prototype.rotate = function() {
    this._currentVersion = (this._currentVersion + 1) % this._versions.length;
  }
  
  Block.prototype.rotated = function() {
    var newBlock = this.clone();
    newBlock.rotate();
    return newBlock;
  }
  
  Block.prototype.points = function(basePoint) {
    return this._versions[this._currentVersion].map(p => ({ x: p[1] + basePoint[1], y: p[0] + basePoint[0] }));
  }
  
  Block.prototype.erase = function(basePoint, board) {
    this.points(basePoint).forEach((p) => {
        board[p.y][p.x].reset();
      });
  }
  
  Block.prototype.draw = function(basePoint, board) {
    this.points(basePoint).forEach((p) => { 
        board[p.y][p.x].set("block " + this._symbol + "-block", this._symbol);
      });
  }
  
  Block.prototype.fasten = function(basePoint, board) {
    this.points(basePoint).forEach((p) => { 
      board[p.y][p.x].set("final " + this._symbol + "-block" , "x");
    });
  }
  
  Block.prototype.wrappedInRedraw = function(basePoint, board, f) {
    this.erase(basePoint, board);
    f();
    this.draw(basePoint, board);
  }
  
  Block.prototype.randomVersion = function() {
    var newBlock = this.clone();
    newBlock._currentVersion = Math.floor(Math.random() * this._versions.length);
    return newBlock;
  }
  
  return Block;
})