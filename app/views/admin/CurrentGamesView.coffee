
_ = require 'lodash'
$ = require 'jquery'
Bacon$ = 'bacon.jquery'
BaconModel = 'bacon.model'
Bacon = 'baconjs'

getIdFromClickEvent = (event) -> return $(event.target).attr('id')

# takes object of currently connected people
# returns div of currently connected people

##  [connectedMarker] subject [userId] 
## (station [num], [elevatedCondition])
##  round [round]: [currentTurn] [done]
currentGamesDiv = (games) ->
	_.template('''
			<% _.forEach(games, function(game) { %>

				<p>

				<% if (game.subject_is_connected) { %> 
					<div class="isConnected">xx</div>
				<% } %>
				<b>subject <%= game.subject_id %></b> 
				<span class = "deleteGame" id="<%= game.subject_id %>">x</span>

				<br>

				<small>
				(station <%= game.station_num %>
				-
				<%= game.elevated_heartrate_condition %>)
				</small>

				<br>

				<b><i>
				round <%= game.round_num %>: 
				<%= game.currentTurn %>
				</b></i>

				<br>

				<% if (game.currentTurn == 'entrustTurn') { %>

					<% if (game.humanState.entrustTurn &&  game.botState.entrustTurn ) { %>
						<span class = "bothDone" id="<%= game.subject_id %>"></span>
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'cooperateDefectTurn') { %>

					<% if (game.humanState.cooperateDefectTurn && game.botState.cooperateDefectTurn) { %>
						<span class = "bothDone" id="<%= game.subject_id %>"></span>
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'readyForNextRound') { %>

					<% if (game.humanState.readyForNextRound && game.botState.readyForNextRound) { %>
						<span class = "bothDone" id="<%= game.subject_id %>"></span>
					<% } %>

				<% } %>

				</p>

			<% }) %>
		''')(games:games)

exports.setup = (games) ->
	# put the html in the div
	$('#currentGames').html(currentGamesDiv(games))
	# when we click a '.bothDone' span,
	$advanceButton = $(".bothDone")
	$deleteGameButton = $(".deleteGame")
	# map clicks to the subject ID of the subject who's game we will advance

	okToAdvanceIdStream = $advanceButton.asEventStream('click')
		.map(getIdFromClickEvent) 
		.map((subject_id) -> {route:'okToAdvance', data: {subject_id: subject_id}})

	deleteGameStream = $deleteGameButton.asEventStream('click')
		.map(getIdFromClickEvent)
		.map((subject_id) -> {route:'deleteGame', data: {subject_id: subject_id}})

	return okToAdvanceIdStream.merge(deleteGameStream)
