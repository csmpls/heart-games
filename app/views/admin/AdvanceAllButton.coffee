$ = require 'jquery'
_ = require 'lodash'

advanceAllPlayersButton = ->
	_.template('''
		<button id = "advanceAllPlayersButton">everyone is READY! - ADVANCE!</button>
		''')()

draw = (socket, games) ->

	$buttonContainer = $('#advanceAllPlayersDiv')

	donePlayers = _.filter(games, (game) ->
		if game.currentTurn == 'entrustTurn'
			if game.humanState.entrustTurn &&  game.botState.entrustTurn
				return game
		if game.currentTurn == 'cooperateDefectTurn'
			if game.humanState.cooperateDefectTurn && game.botState.cooperateDefectTurn
				return game
		if game.currentTurn == 'readyForNextRound'
			if game.humanState.readyForNextRound && game.botState.readyForNextRound
				return game)

	# if everyone is done
	if donePlayers.length == Object.keys(games).length
		$buttonContainer.html(advanceAllPlayersButton())
		$('#advanceAllPlayersButton').asEventStream('click')
			.onValue(() -> 
				socket.emit('advanceAllPlayers'))

	else
		$buttonContainer.empty()

exports.draw = draw