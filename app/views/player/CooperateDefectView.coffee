
_ = require 'lodash'
$ = require 'jquery'
baconModel = require 'bacon.model'
bacon$ = require 'bacon.jquery'
Bacon = require 'baconjs'

opponentEntrustedNothingView = ->

	_.template('''
		<p>Your partner entrusted you with nothing.</p>

		<button id = "okButton">Ok</button>
		''')



opponentEntrustePointsView = (pointsEntrusted) ->
	_.template('''

		<p>Your partner entrusted you with <%= pointsEntrusted %></p>

		<button id="cooperateButton">Return</button>

		<button id="defectButton">Keep</button>

		''')(
		pointsEntrusted: pointsEntrusted)


# show user that their partner didnt entrust them with anything
# returns a stream of clicks on the ok button
setupEntrustedNothingView = ->
	$('#content').html(opponentEntrustedNothingView())
	# return a stream of clicks on the 'ok button'
	# NOTE: we count this 'ok' button as a 'cooperate' in the db etc.
	cooperateTurns = $('#okButton').asEventStream('click').map('cooperate')
	cooperateTurns


# show user that their partner didnt entrust them with anything
# returns a stream of either 'cooperate' or 'defect'
setupEntrustedPointsView = (pointsEntrusted) ->
	# put view html in #content 
	$('#content').html(opponentEntrustePointsView(pointsEntrusted))

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

	# return a stream of decisions
	# either 'cooperate' or 'defect' strings
	cooperateDefectTurns


setup = (opponentEntrustTurn) ->

	pointsEntrusted = opponentEntrustTurn.pointsEntrusted

	userTurns = null

	if pointsEntrusted == 0
		userTurns = setupEntrustedNothingView()

	if pointsEntrusted > 0
		userTurns = setupEntrustedPointsView(pointsEntrusted)

	userTurns

	

exports.setup = setup 

