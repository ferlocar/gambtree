/* Place all the behaviors and hooks related to the matching controller here.
* All this logic will automatically be available in application.js.
* You can use CoffeeScript in this file: http://coffeescript.org/ */

window.onload = function(){
	var fruitIndex = 0;
	var availableFruits = ["apple", "cherry", "banana", "grapes", "strawberry"];
	var colorIndex = 0;
	var availableColors = ["red", "green", "blue", "yellow", "purple"];
	var currentGambfruit = $("#"+availableColors[colorIndex]+"_"+availableFruits[fruitIndex]);
	var currentNumber = 0;
	
	function capitalizeFirstLetter(string) {
	    return string.charAt(0).toUpperCase() + string.slice(1);
	}
	
	function refreshFruit(indexInc) {
		var currentFruit = $("#"+availableFruits[fruitIndex]);
		currentFruit.addClass("hidden_option");
		fruitIndex += indexInc;
		if(fruitIndex >= availableFruits.length)
			fruitIndex = 0;
		else if(fruitIndex < 0)
			fruitIndex = availableFruits.length - 1;
		currentFruit = $("#"+availableFruits[fruitIndex]);
		currentFruit.removeClass("hidden_option");
		refreshGambfruit();
	}
	
	function refreshColor(indexInc) {
		var currentColor = $("#"+availableColors[colorIndex]);
		currentColor.addClass("hidden_option");
		colorIndex += indexInc;
		if(colorIndex >= availableColors.length)
			colorIndex = 0;
		else if(colorIndex < 0)
			colorIndex = availableColors.length - 1;
		currentColor = $("#"+availableColors[colorIndex]);
		currentColor.removeClass("hidden_option");
		refreshGambfruit();
	}
	
	function refreshNumber(inc) {
		var unitsImage = $(".units_" + (currentNumber%10).toString());
		var tensImage = $(".tens_" + Math.floor(currentNumber/10).toString());
		unitsImage.addClass("hidden_option");
		tensImage.addClass("hidden_option");
		currentNumber += inc;
		if(currentNumber >= 100)
			currentNumber = 0;
		else if(currentNumber < 0)
			currentNumber = 99;
		var unitsImage = $(".units_" + (currentNumber%10).toString());
		var tensImage = $(".tens_" + Math.floor(currentNumber/10).toString());
		unitsImage.removeClass("hidden_option");
		tensImage.removeClass("hidden_option");
		refreshGambfruit();
	}
	
	function refreshGambfruit() {
		currentGambfruit.addClass("hidden_option");
		currentGambfruit = $("#"+availableColors[colorIndex]+"_"+availableFruits[fruitIndex]);
		currentGambfruit.removeClass("hidden_option");
		$("#fruit_param").val(availableFruits[fruitIndex]);
		$("#color_param").val(availableColors[colorIndex]);
		$("#number_param").val(currentNumber);
	}
	 
	$( "#decFruit" ).click(function() {
		refreshFruit(-1);
	});
	$( "#incFruit" ).click(function() {
		refreshFruit(1);
	});
	$( "#decColor" ).click(function() {
		refreshColor(-1);
	});
	$( "#incColor" ).click(function() {
		refreshColor(1);
	});
	$( "#decNumber" ).click(function() {
		refreshNumber(-1);
	});
	$( "#incNumber" ).click(function() {
		refreshNumber(1);
	});
	
	refreshFruit(0);
	refreshColor(0);
	refreshNumber(0);
};