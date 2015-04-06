
$ = require 'jquery'
_ = require 'lodash'

turnSummaryView = (turnSummary, bank) ->
	_.template('''
		<p> <%= turnSummary %> </p>

		<p> your bank is <%= bank %> </p>

		<p>READY FOR NEXT TURN</p>
		''')(
		turnSummary: turnSummary 
		bank: bank)

exports.setup = (cooperateDefectTurn) ->
	$('#content').html(turnSummaryView(cooperateDefectTurn.turnSummary, cooperateDefectTurn.bank))