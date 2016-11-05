requirejs(["../bower_components/sizzle/dist/sizzle.min.js"], function(sizzle) {
	const elemById = (id) => sizzle('#' + id)[0];
	
	elemById("points").innerHTML = 0;
	elemById("level").innerHTML = 1;
	
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
				cell.className = "cell";
				matrix[i].push({ value: 'e', elem: cell })
				row.appendChild(cell);
			}
			parent.appendChild(row);
		}
		
		return matrix;
	}
	
	const matrix = drawBoard(elemById("board"), { rows: 20, cols: 10, fieldClass: "field" });
	matrix.forEach((row) => row.forEach((cell) => cell.elem.innerHTML = cell.value))
  
  var blocks = [
    [[0,0], [0,1], [0,2], [0,3]],
    [[0,0], [0,1], [0,2], [1,2]],
    [[0,0], [0,1], [0,2], [-1,2]],
    [[0,0], [0,1], [1,1], [1,2]],
    [[0,0], [0,1], [-1,1], [-1, 2]],
    [[0,0], [0,1], [1,1], [1,0]]
  ];
  
  function setClasses(classes, value) {
    return function(block, board, basePoint) {
      block.forEach((b) => { 
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].value = value;
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].elem.className = classes;
        board[basePoint[0] + b[0]][basePoint[1] + b[1]].elem.innerHTML = value;
      });        
    }
  }
  drawBlock = setClasses("cell block", "b");
  undrawBlock = setClasses("cell", "e");
  finalizeBlock = setClasses("cell final", "x")
  
  function getBase(block, board) {
    return [random([1,2]),random([0,1,2,3,4,5,6])];
  }
  
  function random(x) {
    return x[Math.floor(Math.random()*x.length)];
  }
  
  function nextTurnValid(block, board, basePoint) {
    return block.reduce((acc, b) => {
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
  
  function clearFullLines(board) {
    const fullRows = board.map((row) => {
      return row.reduce((acc, c) => acc && c.value === 'x', true);
    });
    fullRows.forEach((fullRow, k) => {
      if(fullRow) {
        emptify(board[k]);
        pullDown(board, k);
      }
    });
  }
    
  function startGame(board) {
    
    var basePoint = [], block = [];
    window.addEventListener("keydown", (ev) => {
      if(ev.keyCode === 37) {
        if(block.reduce((acc, b) => acc && (basePoint[1] + b[1] > 0) &&
          (board[basePoint[0] + b[0]][basePoint[1] + b[1] - 1].value !== 'x'), true)) {
          undrawBlock(block, board, basePoint);
          basePoint[1]--;
          drawBlock(block, board, basePoint);
        }
      }
      else if(ev.keyCode === 39) {
        if(block.reduce((acc, b) => acc && (basePoint[1] + b[1] + 2 < board[0].length) &&
          (board[basePoint[0] + b[0]][basePoint[1] + b[1] + 1].value !== 'x'), true)) {
          undrawBlock(block, board, basePoint);
          basePoint[1]++;
          drawBlock(block, board, basePoint);
      }
      }
    }, true);
    
    nextBlock(board);
    
    function nextBlock(board) {
      block = Object.assign([], blocks[5]/*random(blocks)*/);
      basePoint = getBase(block, board)
      if(nextTurnValid(block, board, basePoint)){
        drawBlock(block, board, basePoint);
        setTimeout(nextTurn, 100, block, board, basePoint);
      }
      else {
        elemById("game-menu").innerHTML = "GAME OVER!";
        return;
      }
    }
    
    function nextTurn(block, board, basePoint) {
      undrawBlock(block, board, basePoint);
      basePoint[0]++;
      shift = 0;
      if(nextTurnValid(block, board, basePoint)) {
        drawBlock(block, board, basePoint);
        setTimeout(nextTurn, 100, block, board, basePoint);        
      }
      else {
        finalizeBlock(block, board, [basePoint[0] - 1, basePoint[1]]);
        clearFullLines(board);
        nextBlock(board);
      }
    }
  }
  
  startGame(matrix);
});