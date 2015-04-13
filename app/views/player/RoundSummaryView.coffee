
$ = require 'jquery'
_ = require 'lodash'

# TODO update bank 
roundSummaryView = (summary, bank) ->
	_.template('''
		<p> <%= summary %> </p>

		<button id = "readyButton">OK</button>
		''')(
		summary: summary)

exports.setup = (roundSummary) ->
	$('#content').html(roundSummaryView(roundSummary.summary, roundSummary.bank))

	readyForNextRound = $('#readyButton').asEventStream('click')
	
	# a stream of clicks on the 'ready' button
	readyForNextRound
