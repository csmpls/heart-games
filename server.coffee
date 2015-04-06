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

	# PLAYER LOGIN
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

	# when the admin emits a turn event
	# we pass that turn on to everyone in the player namespace
	# TODO eventually, a bot will emit turn events, but WoZ for now
	socket.on('turn', (turn) -> 
		console.log ' T U R N ', turn
		players_ns.emit('turn', turn)))
