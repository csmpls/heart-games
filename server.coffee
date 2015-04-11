path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);

game = require './lib/game.coffee'

port = 3000
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



# players namespace
admins_ns = io.of('/admin')
players_ns = io.of('/players')

# state of all current games
# there are no games right now, but eventually,
# the key of each game is the ID of the player.
games = {}

getRound = (subject_id) -> games[subject_id]

pushGamesToAdmins = -> admins_ns.emit('games', games)

emitToSubject = (subject_id, message, payload) ->
	players_ns.in(subject_id).emit(message, payload)

players_ns
.on('connection', (socket) ->

	#  player login
	socket.on('login', (data) ->
		# save player's id in their socket
		socket.subject_id = data.subject_id
		# we store login data in our games state
		games[data.subject_id] = game.initializeNewGame({
			subject_id: data.subject_id
			station_num: data.station_num })
		# put the socket in a room named after their subject id
		socket.join(data.subject_id)
		players_ns.in(data.subject_id).emit('server says', 'hii')

		# ---
		# START GAME
		# TODO: this will be started by a start message
		# --
		# send a message to get them going
		socket.emit("opponentReadyForNextRound")
		# we set the current turn manually
		round = games[data.subject_id]
		round.currentTurn = 'entrustTurn'
		# tell the bot to play an entrust turn
		round.bot.playEntrustTurn(round, emitToSubject, pushGamesToAdmins, game.checkRoundCompletion)
		# let admins know about the state of the games
		pushGamesToAdmins())

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
	socket.emit('games', games))




