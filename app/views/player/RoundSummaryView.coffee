
$ = require 'jquery'
_ = require 'lodash'

generateHeartrateGraph = require '../../lib/GenerateHeartrateGraph.coffee'

# TODO update bank 
roundSummaryView = (summary) ->
	_.template('''

		<div id="summary">
			<div id = "roundSummary">
				<%= summary %> </p>
			</div>

			<div id = "heartrateSummary">
				<div id = "graphContainer"> </div>
			</div>
		</div>

		<div id = "readyButtonDiv">
			<button id = "readyButton">OK</button>
		</div>
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
