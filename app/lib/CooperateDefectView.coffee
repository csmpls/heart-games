
_ = require 'lodash'
$ = require 'jquery'
baconModel = require 'bacon.model'
bacon$ = require 'bacon.jquery'
Bacon = require 'baconjs'

cooperateDefectView = (decision, pointsEntrusted) ->
	_.template('''

		<p>your partner decided to <%= decision %> 
		with <%= pointsEntrusted %></p>

		<button id="cooperateButton">Cooperate</button>

		<button id="defectButton">Defect</button>

		''')(
		decision: decision
		pointsEntrusted: pointsEntrusted)

setup = (opponentEntrustTurn) ->

	# put view html in #content 
	$('#content').html(cooperateDefectView(opponentEntrustTurn.decision, opponentEntrustTurn.pointsEntrusted))

	# streams of the two buttons
	cooperate = $('#cooperateButton').asEventStream('click')
		.map('cooperate')
	defect = $('#defectButton').asEventStream('click')
		.map('defect')

	# merge button streams into decision
	decision = cooperate.merge(defect).toProperty()

	# create a stream of turns
	# these are objects we can send as json to the server
	cooperateDefectTurns = Bacon.combineTemplate({
		decision: decision
	}).sampledBy(decision)

	# return a stream of turns 
	# (turns taken when user presses a button)
	cooperateDefectTurns

exports.setup = setup 

