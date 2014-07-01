/* Place all the behaviors and hooks related to the matching controller here.
   All this logic will automatically be available in application.js.
  You can use CoffeeScript in this file: http://coffeescript.org/
*/
var showNames = false;

window.onload = function(){
  var canvas = document.getElementById("gambtree"); 
  var ctx = canvas.getContext("2d");
  var nodes = [];
  var maxDrawSize = 100;
          
  leaves.sort(function(a, b) {
    // Sort descending by level 
      return b.lvl - a.lvl;
   });
  var maxLvl = leaves[0].lvl;
  var containerWidth = $("#gambtree").parent().width();
  var hUnit = containerWidth/Math.pow(2, maxLvl - 1);
  var drawSize = Math.min(hUnit,maxDrawSize);
  
  var vUnitSize = maxLvl == 1 ? 1 : sum(maxLvl-1);
  var containerHeight = containerWidth/3;
  var vUnit = (containerHeight-drawSize)/vUnitSize;
  
  canvas.width = containerWidth;
  canvas.height = containerHeight;
  
  var showBtn = $("#show"); 
  showBtn.click(function(){
    showNames = !showNames;
    drawBtree(leaves, showNames);
    if(showBtn.attr('value') == "Show names")
      showBtn.attr('value', "Hide names");
    else
      showBtn.attr('value', "Show names");
  });
  
  var maxLvlWithName = Math.floor(Math.log(containerWidth/maxDrawSize)/Math.LN2);
  
  function sum(n) {
    if(n <= 1)
      return n;
    else
      return n + sum(n-1);
  }
  
  function drawBtree(leaves, showNames){
    ctx.clearRect(0,0,canvas.width,canvas.height);
    for (var i = 0; i < leaves.length; i++) {
      var leaf = leaves[i];
      var coord = getLeafCoordinates(leaf);
      nodes[i] = {minX: coord.x, maxX: coord.x + drawSize, minY: coord.y, maxY: coord.y + drawSize};
      if(leaf.lvl > 1) {
        var parent = {lvl:leaf.lvl-1,posn:Math.floor(leaf.posn/2)};
        drawLine(coord, getLeafCoordinates(parent), leaf.lvl);  
      }
      else {
        drawTrunk(coord);
      }
      if(leaf.is_leaf)
        drawLeaf(leaf, coord);
      else
        drawNode(leaf);
      if(showNames)
        drawName(coord, leaf);
    }
  }
  
  function getLeafCoordinates(leaf){
    var leafX = Math.pow(2, maxLvl - leaf.lvl) * (0.5 + leaf.posn) * hUnit;
    if (leaf.lvl == maxLvl)
      if(maxLvl == 1)
        var leafY = drawSize*1.5/2;
      else
        var leafY = drawSize/2;
    else{
      var difLvl = maxLvl - 1 - leaf.lvl;
      var leafY = (sum(difLvl) + (difLvl + 1)/2) * vUnit + drawSize; 
    }
    return {x: leafX, y: leafY};
  }
  
  function drawNode(leaf){
    var coord = getLeafCoordinates(leaf);
    ctx.beginPath();
    var radius = Math.max(drawSize*(maxLvl - leaf.lvl + 1)/maxLvl,1)/2;
    ctx.arc(coord.x, coord.y, radius, 0, 2 * Math.PI, false);
    ctx.fillStyle = getBackgroundColor(leaf);
    ctx.fill();
    ctx.lineWidth = Math.min(3,drawSize);
    ctx.arc(coord.x, coord.y, radius, 0, 2 * Math.PI, false);
    ctx.strokeStyle = '#5D240A';
    ctx.stroke();
  }
  
  function drawTrunk(coord){
    ctx.fillStyle = '#7F462C';
    if(maxLvl == 1){
      var trunkHeight = containerHeight - drawSize*1.5/2;
    }
    else{
      var trunkHeight =  vUnit * maxLvl/2;
    } 
  	ctx.fillRect(coord.x - drawSize/2, coord.y, drawSize, trunkHeight);
  }
  
  function drawLeaf(leaf, coordinates){
    if (leaf.used_by_player)
      var img = document.getElementById("leaf-used");
    else if (leaf.gambling)
      var img = document.getElementById("leaf-gambling");
    else
      var img = document.getElementById("leaf");
  	
  	var leafSize = drawSize;
  	if (maxLvl == 1) 
      leafSize *= 1.5;
    ctx.drawImage(img, coordinates.x-leafSize/2, coordinates.y-leafSize/2, leafSize, leafSize);
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
      return '#5D240A';
    }
    else if (leaf.gambling){
      return '#5D240A';
    }
    else {
      return '#003300';
    }
  }
  
  function truncateText(text,maxWidth,fontSize){
    truncated = false;
    while(true){
      width = ctx.measureText(text).width+fontSize/2;
      if(width <= maxWidth){
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
    var maxBoxSize = leaf.lvl <= maxLvlWithName ? maxDrawSize : drawSize;
    var fontSize = maxBoxSize/5;
    ctx.font= fontSize + "px Georgia";
    var text = truncateText(leaf.name, maxBoxSize, fontSize);
    var rectWidth = ctx.measureText(text).width+fontSize/2;
    var rectHeight = fontSize*1.5;
    
    // Change origin and dimensions to match true size (a stroke makes the shape a bit larger)
    ctx.lineWidth = 3;
    ctx.strokeStyle = getFontColor(leaf);
    ctx.strokeRect(coord.x-rectWidth/2, coord.y-rectHeight/2, rectWidth, rectHeight);
    ctx.fillStyle = getBackgroundColor(leaf);
    ctx.fillRect(coord.x-rectWidth/2, coord.y-rectHeight/2, rectWidth, rectHeight);
    ctx.fillStyle = ctx.strokeStyle;
    ctx.fillText(text,coord.x-rectWidth/2+fontSize/6,coord.y+fontSize/6);
  }
  
  function drawLine(fromCoordinates, toCoordinates, lvl) {
    ctx.beginPath();
    ctx.moveTo(fromCoordinates.x, fromCoordinates.y);
    ctx.lineTo(toCoordinates.x, toCoordinates.y);
    ctx.lineWidth = Math.max(drawSize*(maxLvl - lvl + 1)/maxLvl,1);
    ctx.strokeStyle = '#7F462C';
    ctx.stroke();
  } 
  
  drawBtree(leaves, showNames);  
};