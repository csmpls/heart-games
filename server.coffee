path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);
_ = require 'lodash'
randomInRange = require 'random-number-in-range'

game = require './modules/game.coffee'
saveTrustGameRound = require './modules/saveTrustGameRound.coffee'
config = require './modules/config.coffee'

port = 29087
publicDir = "#{__dirname}/built-app"
app.use(express.static(publicDir))


# HTTP routes
server.listen(port)
console.log 'server listening on ' + port

app.get("/", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'player.html')))

app.get("/niceguys", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'admin.html')))


# make sure the game 'rounds' database is initialized ok
saveTrustGameRound.syncTrustGameRoundModel()


admins_ns = io.of('/admin')
players_ns = io.of('/players')

# state of all current games
# each round is key'd by the subject's ID (e.g. subject 3 is 3: {gamestate..})
games = {}
# each round object looks like this:
# subjectID: { 
#	subject_id
#   station_num
#	round_num						<- what round subject is on
#	elevated_heartrate_condition
#	subject_is_connected
#	currentTurn						<- entrust, cooperateDefect, readyForNextRound
#	bot 							<- an object, see modules/playerBot.coffee
#	botState 						 
#	humanState 						<- these States describe the player's actions through the game
# }										contains 4 things: 
#										- bank   (an integer, this gets updated after readyForNextRound) 
#										- entrustTurn: {decision, pointsEntrusted} ('entrust', 'entrustNothing')
#										- cooperateDefectTurn: {decision} ('cooperate'/'defect')
#										

getRound = (subject_id) -> games[subject_id]

pushGamesToAdmins = -> admins_ns.emit('games', games)

emitToSubject = (subject_id, message, payload) ->
	players_ns.in(subject_id).emit(message, payload)

startNewGameState = (socket, subject_id, station_num, elevatedHeartrateCondition) ->
	# we store login data in our games state
	games[subject_id] = game.initializeNewGame({
		subject_id: subject_id
		station_num: station_num 
		elevated_heartrate_condition: elevatedHeartrateCondition})




# handle sockets

# if subject has a game, returns that game 
getExistingGame = (subject_id) -> games[subject_id]

players_ns
.on('connection', (socket) ->

	#  player login
	socket.on('login', (data) ->

		existingGame = getExistingGame(data.subject_id)

		# if user tries to login to an existing game
		if existingGame
			# and that player is online,
			if existingGame.subject_is_connected
				# ignore the request
				console.log 'someone tried to log in to this game, but the subject was already online:', existingGame
			# if that subject is not online right now,
			# else
				# give the incumbant log-inner their game state back

				# socket.emit('loginOK', data)
				# # start them over at an entrustTurn
				# socket.subject_id = data.subject_id
				# round = existingGame
				# round.currentTurn = 'entrustTurn'
				# round.subject_is_connected = true
				# round.bot.playEntrustTurn(round, round.bot.humanStateLastRound, emitToSubject, pushGamesToAdmins, game.checkRoundCompletion)
				# socket.emit("startEntrustTurn", {points:config.game.POINTS_ON_NEW_ROUND})
				# socket.join(data.subject_id)
				# pushGamesToAdmins()

		else
			socket.emit('loginOK', data)
			# save player's id in their socket
			socket.subject_id = data.subject_id
			# pick HR condition (0,1,2)
			elevatedHeartrateCondition = randomInRange(0,3)
			# start a new game for this user
			startNewGameState(socket, data.subject_id, data.station_num, elevatedHeartrateCondition)	
			# put the socket in a room named after their subject id
			socket.join(data.subject_id)
			# let the admins know about the new game
			admins_ns.emit('games', games))

	# handle player turns
	socket.on('readyForNextRound', () -> 
		# update game state
		round = getRound(socket.subject_id)
		round.humanState.readyForNextRound = true
		# check if both rounds have been submitted, act if necessary
		game.checkRoundCompletion(round, emitToSubject, pushGamesToAdmins)
		# notify admins
		pushGamesToAdmins())

	socket.on('entrustTurn', (turn) -> 
		# update game state
		round = getRound(socket.subject_id)
		round.humanState.entrustTurn = turn
		# check if both rounds have been submitted, act if necessary
		game.checkRoundCompletion(round, emitToSubject, pushGamesToAdmins)	
		# notify admins..
		pushGamesToAdmins())

	socket.on('cooperateDefectTurn', (turn) -> 
		# update game state
		round = getRound(socket.subject_id)
		round.humanState.cooperateDefectTurn = turn 
		# check if both rounds have been submitted, act if necessary
		game.checkRoundCompletion(round, emitToSubject, pushGamesToAdmins)	
		# notify admins
		pushGamesToAdmins())

	# handle player disconnect
	socket.on('disconnect', () -> 
		# set user's connected status to !connected
		round = getRound(socket.subject_id)
		if round then round.subject_is_connected = false
		pushGamesToAdmins()))

# admin namespace
io.of('/admin')
.on('connection', (socket) -> 

	# when admin connects,
	# give her the state of the games
	socket.emit('games', games)

	# this is the message that lets players advance from turn to turn
	socket.on('okToAdvance', (data) ->
		# get the game round 
		round = getRound(data.subject_id)
		# start it on its next turn
		if round.startNextTurnFn
			round.startNextTurnFn()
		else
			console.log 'ERROR! cant find that game', data.subject_id)

	# advance every player to the next round
	socket.on('advanceAllPlayers', () ->
		_.forEach(games, (round) -> 
			round.startNextTurnFn()))

	# this tells all connected clients to stop playing 
	# and to take the survey
	socket.on('pushSurveyToAll', () ->
		players_ns.emit('startSurvey', {surveyURL: config.experiment.SURVEY_URL}))

	# this deletes a users game
	socket.on('deleteGame', (data) -> 
		console.log 'deleting', data
		# clear the user's game from the game state
		delete games[data.subject_id]
		# update the admins
		pushGamesToAdmins())

	# when admin decides to start the game
	socket.on('startGame', () ->
		# start everyone's game
		_.forEach(games, (round) ->
			# we set the current turn manually
			round.currentTurn = 'entrustTurn'
			# tell the bot to play an entrust turn
			round.bot.playEntrustTurn(round, round.bot.humanStateLastRound, emitToSubject, pushGamesToAdmins, game.checkRoundCompletion))
		# send a message to clients to get them going
		players_ns.emit("startEntrustTurn", {points:config.game.POINTS_ON_NEW_ROUND})
		# let admins know about the state of the games
		pushGamesToAdmins() ))
