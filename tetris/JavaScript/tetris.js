//src/Cell.js
var Cell = (function() {
  function Cell(defaultClass, defaultValue, htmlElement) {
    this._defaultClass = defaultClass;
    this._defaultValue = defaultValue;
    this._htmlElement = htmlElement;
    
    this.reset();
  }
  
  Cell.prototype.reset = function() {
    this._htmlElement.className = this._defaultClass;
    delete this.currentValue;
    delete this.additionalClass;
  }
  
  Cell.prototype.set = function(additionalClass, additionalValue) {
    this._htmlElement.className = this._defaultClass + " " + additionalClass;
    this.currentValue = additionalValue;
    this.additionalClass = additionalClass;
  }
  
  Cell.swap = function(c1, c2) {
    var tempValue = c1.currentValue;
    var tempClassName = c1.additionalClass || "";
    
    c1.set(c2.additionalClass || "", c2.currentValue);
    c2.set(tempClassName, tempValue);
  }
  
  return Cell;
})();

// Board.js
var Board = (function() {
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
  };
    
  Board.isValidBlock = function(board, block, basePoint) {
    return block.points(basePoint).reduce((acc, b) => acc && 
      isInClosedOpenInterval(0, b.x, board[0].length) && 
      isInClosedOpenInterval(0, b.y, board.length) &&
      board[b.y][b.x].currentValue !== 'x', 
    true);
  };
  
  
  Board.getStartPoint = function(board, block) {
    var min = block.points([0,0]).reduce((acc, p) => {
      var x = p.x > acc.x ? acc.x : p.x;
      var y = p.y > acc.y ? acc.y : p.y;
      return { x: x, y: y };
    });
    
    return [-min.y, Math.floor(board[0].length / 2) - 1]; // -1 to compensate right-bias
  };
  
  return Board;
})();

// src/Block.js
var Block = (function() {
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
})();

// src/Controller.js
var Controller = (function() {
  function Controller(game) {
    this._game = game;
    this._keyDownHandler = this.keyDownHandler.bind(this);
    this._keyUpHandler = this.keyUpHandler.bind(this);
    this._visibilityHandler = this.visibilityHandler.bind(this);
    this._isPaused = false;
  }
  
  Controller.prototype.play = function() {
    this._currentTimeout = setTimeout(() => {
      if(this._isPaused || this._game.moveBlockDown()) {
        return this.play();
      }

      this.endListening();
      this._game.over();
    }, this._useFast ? this._game.getFastRoundDelay() : this._game.getNormalRoundDelay());
    this._currentTimeoutAt = Date.now();
  }
  
  Controller.prototype.startListening = function() {
    window.addEventListener("keydown", this._keyDownHandler, true);
    window.addEventListener("keyup", this._keyUpHandler);
    document.addEventListener("visibilitychange", this._visibilityHandler);
  }
  
  Controller.prototype.endListening = function() {
    window.removeEventListener("keydown", this._keyDownHandler, true);
    window.removeEventListener("keyup", this._keyUpHandler);
    document.removeEventListener("visibilitychange", this._visibilityHandler);
  }
  
  Controller.prototype.keyUpHandler = function(ev) {
      if(ev.keyCode === 40) {
        this._useFast = false;
      }
  }
  
  Controller.prototype.keyDownHandler = function(ev) {
    if(ev.keyCode === 80) {
		  this._togglePause();
    }
    if(this._isPaused) {
      return;
    }
    switch(ev.keyCode) {
      case 37:
        this._game.moveBlockLeft();
        break;
      case 38: 
        this._game.rotateBlock();
        break;
      case 39: 
        this._game.moveBlockRight();
        break;
      case 40: 
        this._useFast = true;
        if(this._currentTimeoutAt - Date.now() > this._game.getFastRoundDelay()) {
          clearTimeout(this._currentTimeout);
          this._game.moveBlockDown();
          this.play();p
        }
        ev.preventDefault();
        ev.returnValue = false;
        break;
    }
  }
  
  Controller.prototype.visibilityHandler = function() {
    if(document.visibilityState !== "visible") {
      this._togglePause(true);
    }
  }
  
  Controller.prototype._togglePause = function(value) {
      if(!this._isPaused) {
        this._previousMessage = document.getElementById("message").innerHTML;
        document.getElementById("message").innerHTML = "Pauza";
      }
      else {
        if(!value) {
          document.getElementById("message").innerHTML = this._previousMessage;          
        }
      }    
      this._isPaused = value || !this._isPaused;
  }
  
  return Controller;
})();

// src/BlockGenerator.js
var BlockGenerator = (function() {
  var blocks = [
    new Block('I', [[[0,-1], [0,0], [0,1], [0,2]], [[-1,0], [0,0], [1,0], [2,0]]]),
    new Block('L', [[[0,0], [-1,0], [-1,1], [-1,2]], [[-2,0],[-2,1],[-1,1],[0,1]],
      [[0,0],[0,1],[0,2],[-1,2]], [[-2,0],[-1,0],[0,0],[0,1]]]),
    new Block('F', [[[-1,0],[0,0],[0,1],[0,2]],[[0,0],[-1,0],[-2,0],[-2,1]],
      [[-1,0],[-1,1],[-1,2],[0,2]],[[0,0],[0,1],[-1,1],[-2,1]]]),
    new Block('H', [[[-1,0],[0,0],[1,0],[0,1]],[[0,-1],[0,0],[0,1],[1,0]],
      [[-1,0],[0,0],[1,0],[0,-1]],[[0,-1],[0,0],[0,1],[-1,0]]]),
    new Block('Z', [[[0,0], [0,1], [1,1], [1,2]], [[1,0], [0,0], [0,1], [-1,1]]]),
    new Block('S', [[[1,0], [1,1], [0,1], [0,2]], [[-1,0], [0,0], [0,1], [1,1]]]),
    new Block('O', [[[0,0], [0,1], [1,1], [1,0]]])
  ];
  
  return {
    getBlock: function() {
      return blocks[Math.floor(Math.random() * blocks.length)].randomVersion();
    }    
  };
})();

// src/Game.js
var Game = (function() {
  const defaultFastRoundDelay = 25;
  const defaultNormalRoundDelay = 400;
  const levelCount = 10;
  const linesPerLevel = 10;
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
})();

// src/tetris.js
(function() {	
  function clear(matrix) {
    matrix.forEach(r => r.forEach(c => c.reset()));
    
  }	
  
  const hintBox = new Board(5, 5, "invisible-cell", "").draw(document.getElementById("next-block"));
	const board = new Board(15, 30, "cell", "e").draw(document.getElementById("board"));
  
  function startGame(board, hintBox) {
    document.getElementById("restart").disabled = true;
    clear(hintBox);
    clear(board);
        
    var tetrisGame = new Game(board, hintBox);
    var controller = new Controller(tetrisGame);
    tetrisGame.start();
    controller.startListening();
    controller.play();
  }
  
  document.getElementById("restart").addEventListener("click", function() {
    document.getElementById("message").innerHTML = ""
    startGame(board, hintBox)
  } , true)
})();

