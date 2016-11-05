requirejs(["../bower_components/sizzle/dist/sizzle.min", 
  "./Controller",
  "./Game",
  "./Board"], function(sizzle, Controller, Game, Board) {
	const elemById = (id) => sizzle('#' + id)[0];
	
  var points = 0, level = 1, clearedLines = 0;
	elemById("points").innerHTML = points;
	elemById("level").innerHTML = level;
	
  const hintBox = new Board(5, 5, "invisible-cell", "").draw(elemById("next-block"));
	const matrix = new Board(15, 40, "cell", "e").draw(elemById("board"));
    
  function random(x) {
    return x[Math.floor(Math.random()*x.length)];
  }
  
  
  function startGame(board) {
    var tetrisGame = new Game(board, hintBox);
    var controller = new Controller(tetrisGame);
    tetrisGame.start();
    controller.startListening();
    controller.play();
  }
  
  startGame(matrix);
});