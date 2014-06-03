/* Place all the behaviors and hooks related to the matching controller here.
   All this logic will automatically be available in application.js.
  You can use CoffeeScript in this file: http://coffeescript.org/
*/
window.onload = function(){
  var canvas = document.getElementById("gambtree"); 
  var ctx = canvas.getContext("2d");
  var nodes = [];
          
  leaves.sort(function(a, b) {
    // Sort descending by level 
      return b.lvl - a.lvl;
   });
  var maxLvl = leaves[0].lvl;
  var containerWidth = $(("#gambtree")).parent().width();
  var hUnit = containerWidth/Math.pow(2, maxLvl - 1);
  var drawSize = Math.min(hUnit,100);
  var fontSize = drawSize/5;
  var vUnit = drawSize;
  
  canvas.width = hUnit * Math.pow(2, maxLvl - 1);
  canvas.height = vUnit * maxLvl;
  
  function drawBtree(leaves)
  {
    for (var i = 0; i < leaves.length; i++) {
      var leaf = leaves[i];
      var coord = getLeafCoordinates(leaf);
      nodes[i] = {minX: coord.x, maxX: coord.x + drawSize, minY: coord.y, maxY: coord.y + drawSize};
      if(leaf.lvl > 1)
      {
        var parent = {lvl:leaf.lvl-1,posn:Math.floor(leaf.posn/2)};
        drawLine(coord, getLeafCoordinates(parent));
        drawLeaf(coord);  
      }
      else
      {
        drawTrunk(coord);
      }
      drawName(coord, leaf);
    }
  }
  
  function getLeafCoordinates(leaf){
    var leafX = Math.pow(2, maxLvl - leaf.lvl) * (0.5 + leaf.posn) * hUnit;
    var leafY = (leaf.lvl - 0.5) * vUnit;
    return {x: leafX, y: leafY};
  }
  
  function drawTrunk(coordinates){
  	var img = document.getElementById("trunk");
    ctx.drawImage(img, coordinates.x-drawSize/2, coordinates.y-drawSize/2, drawSize, drawSize);
  }
  
  function drawLeaf(coordinates){
  	var img = document.getElementById("leaf");
    ctx.drawImage(img, coordinates.x-drawSize/2, coordinates.y-drawSize/2, drawSize, drawSize);
  }
  
  function getBackgroundColor(leaf){
    if (leaf.used_by_player){
      return '#FF9900';
    }
    else if (leaf.gambling){
      return '#FFCC33';
    }
    else {
      return '#009933';
    }
  }
  
  function getFontColor(leaf){
    if (leaf.used_by_player){
      return '#996600';
    }
    else if (leaf.gambling){
      return '#996600';
    }
    else {
      return '#003300';
    }
  }
  
  function truncateText(text){
    truncated = false;
    while(true){
      width = ctx.measureText(text).width+fontSize/2;
      if(width <= drawSize){
        return text;
      } 
      else {
        if (!truncated)
          text = text.slice(0, -1);
        else
          text = text.slice(0, -3);
        text += "..";
        truncated = true;
      }
    }
  }
  
  function drawName(coord, leaf){
    // Set faux rounded corners
    ctx.font= fontSize + "px Georgia";
    var text = truncateText(leaf.name);
    rectWidth = ctx.measureText(text).width+fontSize/2;
    rectHeight = fontSize*1.5;
    
    // Change origin and dimensions to match true size (a stroke makes the shape a bit larger)
    ctx.lineWidth = 3;
    ctx.strokeStyle = getFontColor(leaf);
    ctx.strokeRect(coord.x-rectWidth/2, coord.y-rectHeight/2, rectWidth, rectHeight);
    ctx.fillStyle = getBackgroundColor(leaf);
    ctx.fillRect(coord.x-rectWidth/2, coord.y-rectHeight/2, rectWidth, rectHeight);
    ctx.fillStyle = ctx.strokeStyle;
    ctx.fillText(text,coord.x-rectWidth/2+fontSize/6,coord.y+fontSize/6);
  }
  
  function drawLine(fromCoordinates, toCoordinates) {
    ctx.beginPath();
    ctx.moveTo(fromCoordinates.x, fromCoordinates.y);
    ctx.lineTo(toCoordinates.x, toCoordinates.y);
    ctx.lineWidth = Math.max(drawSize/10,1);
    ctx.strokeStyle = '#7F462C';
    ctx.stroke();
  } 
  
  drawBtree(leaves);  
};