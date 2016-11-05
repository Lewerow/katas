define(function() {
  function Cell(defaultClass, defaultValue, htmlElement) {
    this._defaultClass = defaultClass;
    this._defaultValue = defaultValue;
    this._htmlElement = htmlElement;
    
    this.reset();
  }
  
  Cell.prototype.reset = function() {
    this._htmlElement.className = this._defaultClass;
    this._htmlElement.innerHTML = this._defaultValue;
  }
  
  Cell.prototype.set = function(additionalClass, additionalValue) {
    this._htmlElement.className = this._defaultClass + " " + additionalClass;
    this._htmlElement.innerHTML = additionalValue || this._defaultValue;
    this.currentValue = additionalValue;
    this.additionalClass = additionalClass;
  }
  
  Cell.swap = function(c1, c2) {
    var tempValue = c1.additionalValue;
    var tempClassName = c1.additionalClass;
    
    c1.set(c2.additionalClass, c2.additionalValue);
    c2.set(tempClassName, tempValue);
  }
  
  return Cell;
});