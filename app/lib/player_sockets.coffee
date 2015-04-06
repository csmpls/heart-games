io = require './socket.io.js'

exports.setup = (port) ->

	socket = io('http://localhost:' + port + '/players')

	socket.on('turn', (turn) -> turn)
		
	socket