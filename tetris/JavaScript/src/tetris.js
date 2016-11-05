requirejs(["../bower_components/sizzle/dist/sizzle.min.js", "./blocks.js"], function(sizzle, blocks) {
	const elemById = (id) => sizzle('#' + id)[0];
	
  var points = 0, level = 1, clearedLines = 0;
  var fastRound = 30, normalRound = 500;
	elemById("points").innerHTML = points;
	elemById("level").innerHTML = level;
	  
	function drawBoard(parent, config) {
		var i, j;
		var row, cell;
		var matrix = [];
		for(i = 0; i < config.rows; ++i) {
			matrix.push([]);
			row = document.createElement("div");
			row.className = "row";
			for(j = 0; j < config.cols; ++j) {
				cell = document.createElement("div");
				cell.className = config.fieldClass;
				matrix[i].push({ value: 'e', elem: cell })
				row.appendChild(cell);
			}
			parent.appendChild(row);
		}
		
		return matrix;
	}
	
  const hintBox = drawBoard(elemById("next-block"), { rows: 5, cols: 5, fieldClass: "invisible-cell"});
  
  
	const matrix = drawBoard(elemById("board"), { rows: 30, cols: 15, fieldClass: "cell" });
	matrix.forEach((row) => row.forEach((cell) => cell.elem.innerHTML = cell.value))
  
  var v = 0;
  
  function setClasses(classes, value) {
    return function(block, board, basePoint, v) {
      block[v].forEach((b) => { 
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].value = value;
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].elem.className = classes;
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].elem.innerHTML = value;
      });        
    }
  }
  drawBlock = (block, board, basePoint, v) => {
    setClasses("cell block", block.value)(block, board, basePoint, v);
  };
  undrawBlock = setClasses("cell", "e");
  unhintBlock = setClasses("invisible-cell", "");
  finalizeBlock = setClasses("cell final", "x")
  
  function getStartPoint(block, board) {
    return [4,4];
  }
  
  function random(x) {
    return x[Math.floor(Math.random()*x.length)];
  }
  
  function nextTurnValid(block, board, basePoint) {
    return block[v].reduce((acc, b) => {
      return acc && (basePoint[0] + b[0] < board.length) && (basePoint[1] + b[1] < board[0].length) && 
        (basePoint[0] + b[0] >= 0) && (basePoint[1] + b[1] >= 0) && 
        (board[basePoint[0] + b[0]][basePoint[1] + b[1]].value !== 'x');
    }, true);
  }
  
  function emptify(row) {
    row.forEach(cell => {
      cell.value = 'e';
      cell.elem.className = "cell";
      cell.elem.innerHTML = cell.value;
    })
  }
  
  function pullDown(board, toMoveUp) {
    var i;
    for(i = toMoveUp; i > 0; --i) {
      board[i].forEach((v, k) => {
        var tempValue = board[i][k].value;
        var tempClassName = board[i][k].elem.className;
        board[i][k].value = board[i-1][k].value;
        board[i][k].elem.innerHTML = board[i][k].value;
        board[i][k].elem.className = board[i-1][k].elem.className;
        board[i-1][k].value = tempValue;
        board[i-1][k].elem.className = tempClassName;
        board[i-1][k].elem.innerHTML = tempValue;
      });
    }
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
  
  function clearFullLines(board) {
    const fullRows = board.map((row) => {
      return row.reduce((acc, c) => acc && c.value === 'x', true);
    });
    
    const clearedRowCount = fullRows.reduce((a,b) => a + b, 0);
    awardPoints(clearedRowCount);
    fullRows.forEach((fullRow, k) => {
      if(fullRow) {
        emptify(board[k]);
        pullDown(board, k);
      }
    });
  }
  
  function rotate(block) {
    v = (v + 1) % block.length;
  }
  
  function canRotate(block, board, basePoint) {
    return block[(v + 1) % block.length].reduce((acc, b) => acc && 
      (basePoint[0] + b[0] < board.length) && (basePoint[1] + b[1] < board[0].length) && 
      (basePoint[0] + b[0] >= 0) && (basePoint[1] + b[1] >= 0) && 
      (board[basePoint[0] + b[0]][basePoint[1] + b[1]].value !== 'x'), true);
  }
  
  var nextTurnTimeout;
  function startGame(board) {
    var basePoint = [], block = [], isPaused = true, useFast = false;
    window.addEventListener("keydown", (ev) => {
      if(ev.keyCode === 37) {
        if(isPaused) {
          return;
        }
        if(block[v].reduce((acc, b) => acc && (basePoint[1] + b[1] > 0) &&
          (board[basePoint[0] + b[0]][basePoint[1] + b[1] - 1].value !== 'x'), true)) {
          undrawBlock(block, board, basePoint, v);
          basePoint[1]--;
          drawBlock(block, board, basePoint, v);
        }
      }
      else if(ev.keyCode === 38) {
        if(isPaused) {
          return;
        }
        if(canRotate(block, board, basePoint)) {
          undrawBlock(block, board, basePoint, v);
          rotate(block);
          drawBlock(block, board, basePoint, v);
        }
      }
      else if(ev.keyCode === 39) {
        if(isPaused) {
          return;
        }
        if(block[v].reduce((acc, b) => acc && (basePoint[1] + b[1] + 1 < board[0].length) &&
          (board[basePoint[0] + b[0]][basePoint[1] + b[1] + 1].value !== 'x'), true)) {
          undrawBlock(block, board, basePoint, v);
          basePoint[1]++;
          drawBlock(block, board, basePoint, v);
        }
      }
      else if(ev.keyCode === 40) {
        useFast = true;
        nextTurn(block, board, basePoint, true)
      }
	  else if(ev.keyCode === 80) {
		  isPaused = !isPaused;
	  }
    }, true);
    
    window.addEventListener("keyup", (ev) => {
      if(ev.keyCode === 40) {
        useFast = false;
      }
    });
    
    var hintedBlock = Object.assign([], random(blocks));
    var v1 = Math.floor(Math.random() * hintedBlock.length);
    nextBlock(board);
    function nextBlock(board) {
      block = hintedBlock;
      v = v1;
      if(!block[v]) {
        throw new Error();
      }
      unhintBlock(hintedBlock, hintBox, [2,1], v1);
      hintedBlock = Object.assign([], random(blocks));
      v1 = Math.floor(Math.random() * hintedBlock.length);
      drawBlock(hintedBlock, hintBox, [2,1], v1);
      basePoint = getStartPoint(block, board)
      if(nextTurnValid(block, board, basePoint)){
        drawBlock(block, board, basePoint, v);
        setTimeout(nextTurn, useFast ? fastRound : normalRound, block, board, basePoint);          
      }
      else {
        elemById("game-menu").innerHTML = "GAME OVER!";
        return;
      }
    }
    
    function nextTurn(block, board, basePoint, calledAsFast) {
      if(isPaused) {
        setTimeout(nextTurn, useFast ? fastRound : normalRound, block, board, basePoint);
        return;			  
      }
      undrawBlock(block, board, basePoint, v);
      basePoint[0]++;
      shift = 0;
      if(nextTurnValid(block, board, basePoint)) {
        drawBlock(block, board, basePoint, v);
        if(!calledAsFast) {
          setTimeout(nextTurn, useFast ? fastRound : normalRound, block, board, basePoint);
        }
      }
      else {
        finalizeBlock(block, board, [basePoint[0] - 1, basePoint[1]], v);
        clearFullLines(board);
        nextBlock(board);
      }
    }
  }
  
  startGame(matrix);
});