path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);
_ = require 'lodash'

game = require './modules/game.coffee'
fiftyFiftyChance = require './modules/fiftyFiftyChance.coffee'
saveTrustGameRound = require './modules/saveTrustGameRound.coffee'

port = 29087
publicDir = "#{__dirname}/built-app"
app.use(express.static(publicDir))


# HTTP routes
server.listen(port)
console.log 'server listening on ' + port

app.get("/", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'player.html')))

app.get("/admin", (req, res) ->
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

startNewGame = (socket, subject_id, station_num, elevatedHeartrateCondition) ->
	# save player's id in their socket
	socket.subject_id = subject_id
	# we store login data in our games state
	games[subject_id] = game.initializeNewGame({
		subject_id: subject_id
		station_num: station_num 
		elevated_heartrate_condition: elevatedHeartrateCondition})
	# put the socket in a room named after their subject id
	socket.join(subject_id)



# handle sockets

# if subject has a game, returns that game 
doesUserHaveGame = (id) ->
	try
		games[data.subject_id]
	catch
		false


players_ns
.on('connection', (socket) ->

	#  player login
	socket.on('login', (data) ->

		# pick conditions
		# (these are true or false)
		elevatedHeartrateCondition = fiftyFiftyChance() 
		# start a new game for this user
		startNewGame(socket, data.subject_id, data.station_num, elevatedHeartrateCondition)	
		# let the admins know about the new game
		admins_ns.emit('games', games)
		# send the new player a test message 
		players_ns.in(data.subject_id).emit('server says', 'hii'))

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
		if games[socket.subject_id] then games[socket.subject_id].subject_is_connected = false
		pushGamesToAdmins()))

# admin namespace
io.of('/admin')
.on('connection', (socket) -> 

	# when admin connects,
	# give her the state of the games
	socket.emit('games', games)

	# this is the message that lets players advance from turn to turn
	socket.on('okToAdvance', () ->
		_.forEach(games, (round) ->
			round.startNextTurnFn()))

	# this is the message that clears all the admin games
	socket.on('clearGames', () -> 
		games = {}
		pushGamesToAdmins())

	# when admin decides to start the game
	socket.on('startGame', () ->
		# start everyone's game
		_.forEach(games, (round) ->
			# we set the current turn manually
			round.currentTurn = 'entrustTurn'
			# # tell the bot to play an entrust turn
			round.bot.playEntrustTurn(round, round.bot.humanStateLastRound, emitToSubject, pushGamesToAdmins, game.checkRoundCompletion))
		# send a message to get them going
		players_ns.emit("startEntrustTurn", {points:10})
		# let admins know about the state of the games
		pushGamesToAdmins() ))

	




