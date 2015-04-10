io = require './socket.io.js'

exports.setup = (port) ->

	socket = io('http://localhost:' + port + '/players')

	socket.on('opponentReadyforNextRound', (ready) -> ready)
	socket.on('opponentEntrustTurn', (entrustTurn) -> entrustTurn)
	socket.on('turnSummary', (summary) -> summary)
		
	socket