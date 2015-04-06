
$ = require 'jquery'
_ = require 'lodash'

entrustView = (bank) ->
	_.template('''
		<p> your bank is <%= bank %> </p>

		<p>how many points would you like to entrust to your partner?</p>
		''')(bank: bank)

exports.setup = (readyForNextTurn) ->
	$('#content').html(entrustView(readyForNextTurn.bank))