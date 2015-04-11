path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);

playerBot = require './app/lib/playerBot.coffee'

port = 3000
publicDir = "#{__dirname}/built-app"
app.use(express.static(publicDir))

# setTimeout helper function
# puts callback last
delay = (ms, func) -> setTimeout func, ms

# takes object data: {subject_id, station_num, humanBank, botBank}
# returns an object representing a round
initializeNewRound = (data) ->
	return { 
		# save the socket
		subject_id: data.subject_id
		station_num: data.station_num
		subject_is_connected: true
		# make them a bot to play against
		bot: playerBot
		# bot game state
		botState: {
			entrustTurn: null
			cooperateDefectTurn: null
			readyForNextRound: null
			bank: data.botBank
		}
		# human game state 
		humanState: {
			entrustTurn: null
			cooperateDefectTurn: null
			readyForNextRound: null
			bank: data.humanBank
		}
	}

# HTTP routes
server.listen(port)
console.log 'server listening on ' + port

app.get("/", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'player.html')))

app.get("/admin", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'admin.html')))

# state of all current games
# there are no games right now, but eventually,
# the key of each game is the ID of the player.
games = {}

getRound = (subject_id) -> games[subject_id]

# players namespace
admins_ns = io.of('/admin')
players_ns = io.of('/players')

players_ns
.on('connection', (socket) ->

	# handle player login
	socket.on('login', (data) ->
		# save player's id in their socket
		socket.subject_id = data.subject_id
		# make player join a room named by player's id
		socket.join(String(data.subject_id))
		# we store login data in our games state
		games[data.subject_id] = initializeNewRound({
			subject_id: data.subject_id
			station_num: data.station_num
			humanBank:0
			botBank:0})
		# send a message to get them going
		# TODO: this is not how we should start a game
		# TODO: should start w a start message
		socket.emit("opponentReadyForNextRound")
		console.log ' G A M E S', games
		# let admins know about the state of the games
		admins_ns.emit('games', games))

	# handle player turns
	socket.on('readyForNextRound', () -> 
		# update game state
		subj_id = socket.subject_id
		getRound(subj_id).humanState.readyForNextRound = true
		# notify admins
		admins_ns.emit('games', games))

	socket.on('entrustTurn', (turn) -> 
		# update game state
		subj_id = socket.subject_id
		getRound(subj_id).humanState.entrustTurn = turn
		# notify admins..
		console.log ' G A M E S (new)', games
		admins_ns.emit('games', games))

	socket.on('cooperateDefectTurn', (turn) -> 
		# update game state
		subj_id = socket.subject_id
		getRound(subj_id).humanState.cooperateDefectTurn = turn 
		# notify admins
		admins_ns.emit('games', games))

	# handle player disconnect
	socket.on('disconnect', () -> 
		# set user's connected status to !connected
		if games[socket.subject_id] then games[socket.subject_id].subject_is_connected = false
		console.log ' G A M E S', games
		# let the admins know about the state of the games
		admins_ns.emit('games', games)))

# admin namespace
io.of('/admin')
.on('connection', (socket) -> 

	# when admin connects,
	# give her the state of the games
	socket.emit('games', games)

	# ---- DEBUG ------
	# we're controlling the bot's movements by hand
	# ---- DBUG -------

	socket.on('botReadyForNextRound', (data) -> 
		# this is how the bot acts:
		round = getRound(data.subject_id)
		# setup entrust turn
		delay(round.bot.getTimeoutDelay('readyForNextRound')
			, () -> 
				round = round.bot.playEntrustTurn(round)
				admins_ns.emit('games', games)))

	socket.on('botEntrustTurn', (data) -> 
		round = getRound(data.subject_id)
		# setup cooperate/defect turn
		delay(round.bot.getTimeoutDelay('cooperateDefectTurncooperate')
			, () -> 
				round = round.bot.playCooperateDefectTurn(round)
				admins_ns.emit('games', games)))

	socket.on('botCooperateDefectTurn', (data) -> 
		round = getRound(data.subject_id)
		# setup ready for next round message
		delay(round.bot.getTimeoutDelay('readyForNextRound')
			, () -> 
				round = round.bot.playReadyForNextRound(round)
				console.log 'GAMES again', games
				admins_ns.emit('games', games)))
)



	# ---- DEBUG ------
	# We're faking the server's messages
	# when /admin emits a turn event
	# we pass that turn on to everyone in the player namespace
	# ---- DBUG -------

	# socket.on('opponentReadyForNextRound', (turn) -> 
	# 	console.log 'admin ready 4 next round'
	# 	players_ns.emit('opponentReadyForNextRound'))

	# socket.on('opponentEntrustTurn', (turn) -> 
	# 	console.log 'admin entrust T U R N ', turn
	# 	players_ns.emit('opponentEntrustTurn', turn))

	# socket.on('roundSummary', (summary) -> 
	# 	console.log 'admin S U M M A R Y ',summary 
	# 	players_ns.emit('roundSummary', summary)))

