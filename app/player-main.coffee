Bacon = require 'baconjs'
$ = require 'jquery'
player_sockets = require './lib/player_sockets.coffee'

example_view = require './lib/view.coffee'
cooperateDefectView = require './lib/CooperateDefectView.coffee'
entrustView = require './lib/EntrustView.coffee'
turnSummaryView = require './lib/TurnSummaryView.coffee'

# helper functions to filter turnStream
readyForNextTurn = (turn) -> turn.turnType == 'readyForNextTurn'
entrustTurn = (turn) -> turn.turnType == 'entrust' 
cooperateDefectTurn = (turn) -> turn.turnType == 'cooperateDefect'

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


	# a stream of turn messages from the server
	turnStream = Bacon.fromEventTarget(socket, 'turn')

	# when opponent's "ready" for the next turn msg comes in, 
	turnStream.filter(readyForNextTurn)
		# show the entrust view
		.onValue((turn) -> entrustView.setup(turn.turnData))

	# when opponent's "entrust" turn comes in, 
	turnStream.filter(entrustTurn)
		# show the cooperate/defect view
		.onValue((turn) -> cooperateDefectView.setup(turn.turnData))

	# when opponent's "cooperate/defect" turn message comes in,
	turnStream.filter(cooperateDefectTurn)
		# show the summary view
		.onValue((turn) -> turnSummaryView.setup(turn.turnData))

	console.log 'player app launched ok'

# launch the app
$(document).ready(() ->
	init())
