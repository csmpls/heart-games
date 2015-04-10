path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);

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

# state of all current games
# there are no games right now, but eventually,
# the key of each game is the ID of the player.
games = {}

# players namespace
admins_ns = io.of('/admin')
players_ns = io.of('/players')

players_ns
.on('connection', (socket) ->

	# handle player login
	socket.on('login', (data) ->
		# we associate this socket with its subject_id
		socket.subject_id = data.subject_id
		# we store login data in our games state
		games[data.subject_id] = {
			subject_id: data.subject_id
			station_num: data.station_num
			subject_is_connected: true}
		console.log ' G A M E S', games
		# and let admins know about the state of the games
		admins_ns.emit('games', games))

	# handle player turns
	socket.on('readyForNextRound', (turn) -> 
		console.log 'ready 4 next round')

	socket.on('entrustTurn', (turn) -> 
		console.log 'entrust T U R N ', turn)

	socket.on('cooperateDefectTurn', (turn) -> 
		console.log 'cd T U R N ', turn)

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
	# We're faking the server's messages
	# when the admin emits a turn event
	# we pass that turn on to everyone in the player namespace
	# ---- DBUG -------

	# this turn comes straight from the client
	socket.on('opponentReadyForNextRound', (turn) -> 
		console.log 'admin ready 4 next round'
		players_ns.emit('opponentReadyForNextRound'))

	# this turn comes straight from the client
	socket.on('opponentEntrustTurn', (turn) -> 
		console.log 'admin entrust T U R N ', turn
		players_ns.emit('opponentEntrustTurn', turn))

	# this turn is an interpration
	socket.on('turnSummary', (summary) -> 
		console.log 'admin S U M M A R Y ',summary 
		players_ns.emit('turnSummary', summary)))

