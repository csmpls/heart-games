Bacon = require 'baconjs'
$ = require 'jquery'
player_sockets = require './lib/player_sockets.coffee'
cooperateDefectView = require './views/player/CooperateDefectView.coffee'
entrustView = require './views/player/EntrustView.coffee'
roundSummaryView = require './views/player/RoundSummaryView.coffee'
waitingView = require './views/player/WaitingView.coffee'
headerBarView = require './views/player/HeaderBarView.coffee'
pointsThisRoundView = require './views/player/PointsThisRoundView.coffee'

init = ->

	# config
	socketURL = 'http://trust.coolworld.me/players'
	subject_id = 0
	station_num = 42 

	# setup socket
	socket = player_sockets.setup(socketURL)


	#
	# login
	# 

	# emit login event
	socket.emit('login', {
		subject_id:subject_id
		station_num: station_num })


	#
	# setup game view
	#

	# setup header (bank starts at 0)
	headerBarView.setup(subject_id, station_num, 0)

	# show that we're waiting for the administrator to start the game
	waitingView.waitingFor('the experimenter to start the game')



	#
	# entrust turn
	#

	startEntrustTurnStream = Bacon.fromEventTarget(socket, 'startEntrustTurn')
	startEntrustTurnStream.onValue((nextTurn) ->
		# start the round by showing the entrust view
		entrustTurns = entrustView.setup()
		# and replenish our points for this round
		# this value comes from the server
		points_this_round = nextTurn.points
		pointsThisRoundView.setup(points_this_round)
		# on every enturst turn
		entrustTurns.onValue((playerTurn) -> 
			# update 'points this round' 
			points_this_round -= playerTurn.pointsEntrusted
			# and points this round display
			pointsThisRoundView.setup(points_this_round)
			# emit the turn, 
			socket.emit('entrustTurn', playerTurn)
			# & display a waiting screen
			waitingView.waitingFor('all players')))


	#
	#  cooperate/defect turn
	#

	startCooperateDefectTurnStream = Bacon.fromEventTarget(socket, 'startCooperateDefectTurn')
	# show the cooperate/defect view
	startCooperateDefectTurnStream.onValue((entrustTurn) ->
		cooperateDefectTurns = cooperateDefectView.setup(entrustTurn)
		cooperateDefectTurns.onValue((playerTurn) ->
			# emit cooperate/defect turns 
			socket.emit('cooperateDefectTurn', playerTurn)
			# & display waiting screen
			waitingView.waitingFor('all players')))


	#
	# round summary turn
	#

	# when opponent's "cooperate/defect" turn message comes in,
	# the server sends us a summary of the turn.
	roundSummaryStream = Bacon.fromEventTarget(socket, 'roundSummary').log()
	roundSummaryStream.onValue((roundSummary) ->
		# update the header bar
		headerBarView.setup(subject_id, station_num, roundSummary.bank)
		# show the summary view
		readyForNextRound = roundSummaryView.setup(roundSummary)
		readyForNextRound.onValue((readyMessage) ->
			# emit 'ready' message 
			socket.emit('readyForNextRound')
			# & display waiting screen
			waitingView.waitingFor('all players')))

	console.log 'player app launched ok'

# launch the app
$(document).ready(() ->
	init())
