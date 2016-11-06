define(function() {
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
});