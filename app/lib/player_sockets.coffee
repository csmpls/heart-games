io = require './socket.io.js'

exports.setup = (socketURL) ->

	socket = io(socketURL)

	socket.on('server says', (msg) -> 
		console.log 'server says', msg)

	socket.on('startEntrustTurn', (data) -> data)
	socket.on('startCooperateDefectTurn', (data) -> data)
	socket.on('turnSummary', (summary) -> summary)
		
	socket