define(["./Board"], function(Board) {
  function Controller(game) {
    this._game = game;
  }
  
  var fastRound = 30, normalRound = 500, isPaused = true;  
  Controller.prototype.play = function() {
    setTimeout(() => {
      if(this._game.moveBlockDown() || this._game.nextBlock()) {
        return this.play();
      }

      this._game.over();     
      
    }, this._useFast ? fastRound : normalRound);
  }
  
  Controller.prototype.startListening = function() {
    window.addEventListener("keydown", (ev) => {
      if(ev.keyCode === 37) {
        if(isPaused) {
          return;
        }
        this._game.moveBlockLeft();
      }
      else if(ev.keyCode === 38) {
        if(isPaused) {
          return;
        }
        this._game.rotateBlock();
      }
      else if(ev.keyCode === 39) {
        if(isPaused) {
          return;
        }
        this._game.moveBlockRight();
      }
      else if(ev.keyCode === 40) {
        useFast = true;
        this._game.moveBlockDown();
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
  }
  
  return Controller;
})