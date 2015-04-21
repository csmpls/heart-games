
$ = require 'jquery'
_ = require 'lodash'

generateHeartrateGraph = require '../../lib/GenerateHeartrateGraph.coffee'

# TODO update bank 
roundSummaryView = (summary) ->
	_.template('''
		<p> <%= summary %> </p>

		<p> Your partner's heartrate during the last round: </p>

		<div id = "graphContainer"> </div>

		<button id = "readyButton">OK</button>
		''')(
		summary: summary)

exports.setup = (roundSummary) ->

	# load summary into the view
	$('#content').html(roundSummaryView(roundSummary.summary))

	# add heartrate to the view
	hr = roundSummary.opponentHeartrate
	generateHeartrateGraph(hr.mean, hr.std, hr.interpretation, 'graphContainer')

	readyForNextRound = $('#readyButton').asEventStream('click')
	
	# a stream of clicks on the 'ready' button
	readyForNextRound
