/* Place all the behaviors and hooks related to the matching controller here.
   All this logic will automatically be available in application.js.
  You can use CoffeeScript in this file: http://coffeescript.org/
*/
window.onload = function(){
  var canvas = document.getElementById("gambtree"); 
  var ctx = canvas.getContext("2d");
          
  leaves.sort(function(a, b) {
    // Sort descending by level 
      return b.lvl - a.lvl;
   });
  var maxLvl = 0;
  for (var i = 0; i < leaves.length; i++) { 
      if (leaves[i].lvl > maxLvl) {
        maxLvl = leaves[i].lvl; 
      }
  }
  var containerWidth = $(("#gambtree")).parent().width();
  var maxMargin = 40;
  console.log(containerWidth);
  var hUnit = Math.min(containerWidth-maxMargin)/Math.pow(2, maxLvl - 1);
  var vUnit = hUnit;
  var radius = Math.min(hUnit, vUnit)/4;
  
  canvas.width = hUnit * Math.pow(2, maxLvl - 1);
  canvas.height = vUnit * maxLvl;
  
  function drawBtree(leaves)
  {
    for (var i = 0; i < leaves.length; i++) {
      var leaf = leaves[i];
      var leafCoordinates = getLeafCoordinates(leaf);
      if(leaf.lvl > 1)
      {
        var parent = {lvl:leaf.lvl-1,posn:Math.floor(leaf.posn/2)};
        drawLine(leafCoordinates, getLeafCoordinates(parent));  
      }
      drawCircle(leafCoordinates);
    }
  }
  
  function getLeafCoordinates(leaf){
    var leafX = Math.pow(2, maxLvl - leaf.lvl) * (0.5 + leaf.posn) * hUnit;
    var leafY = (leaf.lvl - 0.5) * vUnit;
    return {x: leafX, y: leafY};
  }
  
  function drawCircle(coordinates){
    ctx.beginPath();
    ctx.arc(coordinates.x, coordinates.y, radius, 0, 2 * Math.PI, false);
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#003300';
    ctx.fillStyle = 'green';
    ctx.fill();
    ctx.stroke();
  }
  
  function drawLine(fromCoordinates, toCoordinates) {
    ctx.beginPath();
    ctx.moveTo(fromCoordinates.x, fromCoordinates.y);
    ctx.lineTo(toCoordinates.x, toCoordinates.y);
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#003300';
    ctx.stroke();
  } 
  
  drawBtree(leaves);  
};