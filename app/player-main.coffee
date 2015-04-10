Bacon = require 'baconjs'
$ = require 'jquery'
player_sockets = require './lib/player_sockets.coffee'

example_view = require './lib/view.coffee'
cooperateDefectView = require './views/player/CooperateDefectView.coffee'
entrustView = require './views/player/EntrustView.coffee'
roundSummaryView = require './views/player/RoundSummaryView.coffee'
waitingView = require './views/player/WaitingView.coffee'

init = ->

	port = 3000
	subject_id = 1
	station_num = 42 

	# console.log 'main app launching'
	example_view.setup()

	# setup socket
	socket = player_sockets.setup(port)

	# emit login event
	socket.emit('login', {
		subject_id:subject_id
		station_num: station_num })

	# when opponent's "ready for next round" message comes in, 
	opponentReadyForNextRoundStream = Bacon.fromEventTarget(socket, 'opponentReadyForNextRound')
	# start the round by showing the entrust view
	opponentReadyForNextRoundStream.onValue(() ->
		entrustTurns = entrustView.setup()
		# on every enturst turn
		entrustTurns.onValue((playerTurn) -> 
			# emit the turn, 
			socket.emit('entrustTurn', playerTurn)
			# & display a waiting screen
			waitingView.waitingFor('opponent')))

	# when opponent's "entrust" turn comes in, 
	opoponentEntrustTurnStream = Bacon.fromEventTarget(socket, 'opponentEntrustTurn')
	# show the cooperate/defect view
	opoponentEntrustTurnStream.onValue((entrustTurn) ->
		cooperateDefectTurns = cooperateDefectView.setup(entrustTurn)
		cooperateDefectTurns.onValue((playerTurn) ->
			# emit cooperate/defect turns 
			socket.emit('cooperateDefectTurn', playerTurn)
			# & display waiting screen
			waitingView.waitingFor('opponent')))

	# when opponent's "cooperate/defect" turn message comes in,
	# the server sends us a summary of the turn.
	roundSummaryStream = Bacon.fromEventTarget(socket, 'roundSummary').log()
	# show the summary view
	roundSummaryStream.onValue((roundSummary) ->
		readyForNextRound = roundSummaryView.setup(roundSummary)
		readyForNextRound.onValue((readyMessage) ->
			# emit 'ready' message 
			socket.emit('readyForNextRound')
			# & display waiting screen
			waitingView.waitingFor('opponent to begin next round')))

	console.log 'player app launched ok'

# launch the app
$(document).ready(() ->
	init())
