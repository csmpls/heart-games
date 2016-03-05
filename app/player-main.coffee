Bacon = require 'baconjs'
$ = require 'jquery'
player_sockets = require './lib/player_sockets.coffee'
cooperateDefectView = require './views/player/CooperateDefectView.coffee'
entrustView = require './views/player/EntrustView.coffee'
roundSummaryView = require './views/player/RoundSummaryView.coffee'
waitingView = require './views/player/WaitingView.coffee'
headerBarView = require './views/player/HeaderBarView.coffee'
pointsThisRoundView = require './views/player/PointsThisRoundView.coffee'
loginView = require './views/player/LoginView.coffee'
startSurveyView = require './views/player/StartSurveyView.coffee'

init = ->

	# config
	socketURL = 'trust.coolworld.me/players'
	#socketURL = 'http://localhost:29087/players'
	# subject_id = 0
	# station_num = 42 

	# setup socket
	socket = player_sockets.setup(socketURL)


	#
	# login view
	# 
	loginStream = loginView.setup()

	# on a login event,
	loginStream.onValue((loginData) ->

		# emit login event
		socket.emit('login', loginData))


	# when the server says 'ok' to our login request,
	Bacon.fromEventTarget(socket, 'loginOK').onValue((loginData) ->
		# setup the rest of this program: 


		#
		# main view + header
		#

		# setup header (bank starts at 0)
		headerBarView.setup(loginData.subject_id, loginData.station_num, 0)

		# show that we're waiting for the administrator to start the game
		waitingView.waitingFor('the experimenter to start the game')


		#
		# entrust turn
		#
		startEntrustTurnStream = Bacon.fromEventTarget(socket, 'startEntrustTurn')
		startEntrustTurnStream.onValue((nextTurn) ->
			# replenish our points for this round
			# this value comes from the server
			pointsThisRound = nextTurn.points
			pointsThisRoundView.setup(pointsThisRound)
			# and start the round by showing the entrust view
			entrustTurns = entrustView.setup(pointsThisRound)

			# on every enturst turn
			entrustTurns.onValue((playerTurn) -> 
				# update 'points this round' 
				pointsThisRound -= playerTurn.pointsEntrusted
				# and points this round display
				pointsThisRoundView.setup(pointsThisRound)
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
		roundSummaryStream = Bacon.fromEventTarget(socket, 'roundSummary')
		roundSummaryStream.onValue((roundSummary) ->
			console.log('ROUND SUMMARY', roundSummary)
			# update the header bar
			headerBarView.setup(loginData.subject_id, loginData.station_num, roundSummary.bank)
			# show the summary view
			readyForNextRound = roundSummaryView.setup(roundSummary)
			# clear the points this round view for now
			pointsThisRoundView.setup()
			readyForNextRound.onValue((readyMessage) ->
				# emit 'ready' message 
				socket.emit('readyForNextRound')
				# & display waiting screen
				waitingView.waitingFor('all players')))


		#
		# start survey
		#

		# at the end of the experiment,
		# the server will push a 'startSurvey' event 
		# {surveyURL} 
		startSurveyStream = Bacon.fromEventTarget(socket, 'startSurvey')
		startSurveyStream.onValue((startSurvey) ->
			startSurveyView.setup(startSurvey.surveyURL)))

# launch the app
$(document).ready(() ->
	init())
