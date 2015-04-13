io = require './socket.io.js'

exports.setup = (port) ->

	socket = io('http://localhost:' + port + '/players')

	socket.on('server says', (msg) -> 
		console.log 'server says', msg)

	socket.on('startEntrustTurn', (data) -> data)
	socket.on('startCooperateDefectTurn', (data) -> data)
	socket.on('turnSummary', (summary) -> summary)
		
	socket