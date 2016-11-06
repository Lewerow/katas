requirejs(["./Controller",
  "./Game",
  "./Board"], function(Controller, Game, Board) {
	
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
});