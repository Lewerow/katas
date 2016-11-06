define(["./Board"], function(Board) {
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
})