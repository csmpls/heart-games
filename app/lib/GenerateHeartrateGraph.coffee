_ = require 'lodash'
chart = require './Chart-ErrorBars.js'

randomScalingFactor = () ->
	Math.round(Math.random()*100)

getBarChartData = (mean, std) -> 
	return labels : [""]
		, datasets : [
			fillColor : "rgba(220,220,220,0.0)"
			, strokeColor : "rgba(244,244,244,1)"
			, highlightFill: "rgba(220,220,220,0.0)"
			, highlightStroke: "rgba(220,220,220,1)"
			, data : [mean]
			, error : [std]
		]

getGlobalChartOptions = () -> 
	return scaleShowGridLines : false
		, responsive : false
		, showTooltips: false
		, scaleOverride: true
		, scaleSteps: 100
		, scaleStepWidth: 1
		, scaleStartValue: 0
		, scaleShowLabels: false

heartrateGraphTemplate = (interpretation) ->
	_.template(
		"<p><b>Partner's average heartrate during last turn</b>" +
		'<canvas id="heartrateGraph" width="170px" height="270px"></canvas>' +
		'<br> <%= interpretation %></p> ')(interpretation: interpretation)	


# our export is a function that takes a mean and standard deviation
# and puts a bargraph in #heartrateGraph
generateHeartrateGraph = (heartrate_mean, heartrate_std, interpretation, divID) -> 

	# set up the graph container with a messgae
	document.getElementById(divID)
		.innerHTML = heartrateGraphTemplate(interpretation)

	## draw the graph
	ctx = document.getElementById("heartrateGraph").getContext("2d");
	window.myBar = new Chart(ctx).Bar(
		getBarChartData(heartrate_mean, heartrate_std)
		, getGlobalChartOptions()
	)

module.exports = generateHeartrateGraph