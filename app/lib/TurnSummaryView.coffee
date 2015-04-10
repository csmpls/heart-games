
$ = require 'jquery'
_ = require 'lodash'

# TODO update bank 
turnSummaryView = (summary, bank) ->
	_.template('''
		<p> <%= summary %> </p>

		<button id = "readyButton">Ready for the next turn.</button>
		''')(
		summary: summary)

exports.setup = (turnSummary) ->
	$('#content').html(turnSummaryView(turnSummary.summary, turnSummary.bank))

	readyForNextRound = $('#readyButton').asEventStream('click')
	
	# a stream of clicks on the 'ready' button
	readyForNextRound
