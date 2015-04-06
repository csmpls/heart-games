
$ = require 'jquery'
_ = require 'lodash'

cooperateDefectView = (decision, pointsEntrusted, bank) ->
	_.template('''

		<p>your partner decided to <%= decision %> 
		with <%= pointsEntrusted %></p>

		<p> your bank is now <%= bank %> </p>

		now you can COOPERATE or DEFECT
		''')(
		decision: decision
		pointsEntrusted: pointsEntrusted
		bank: bank)

# we display this view when we get an Entrust turn
exports.setup = (entrustTurn) ->
	$('#content').html(cooperateDefectView(entrustTurn.decision, entrustTurn.pointsEntrusted, entrustTurn.bank))