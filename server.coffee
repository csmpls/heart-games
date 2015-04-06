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

# namespaces
players = io.of('/players')
admins = io.of('/admin')

players
.on('connection', (socket) ->

	# player socket provides us with their data 
	socket.on('login', (data) ->

		# we store this in our object
		games[data.subject_id] = {
			subject_id: data.subject_id
			station_num: data.station_num}
		console.log 'games:', games

		# now we let the admins know about the state of the games
		admins.emit(games)))

# admin namespace
admins
.on('connection', (socket) -> 

	# when admin connects,
	# give her the state of the games
	socket.emit('games', games)

	# when the admin emits a turn event
	# we pass that turn on to everyone in the player namespace
	socket.on('turn', (turn) -> players.emit(turn)))
