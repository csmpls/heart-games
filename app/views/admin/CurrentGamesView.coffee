
_ = require 'lodash'
$ = require 'jquery'

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

				<br>

				<small>
				(station <%= game.station_num %>, 
				<%= game.elevated_heartrate_condition %>)
				</small>

				<br>

				<b><i>
				round <%= game.round_num %>: 
				<%= game.currentTurn %>
				</b></i>

				<br>

				<% if (game.currentTurn == 'entrustTurn') { %>

					<% if (game.humanState.entrustTurn && <%= game.botState.bank %>) { %>
						<span class = "bothDone" [x]></span>
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'cooperateDefectTurn') { %>

					<% if (game.humanState.cooperateDefectTurn && game.botState.cooperateDefectTurn) { %>
						<span class = "bothDone" [x]></span>
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'readyForNextRound') { %>

					<% if (game.humanState.readyForNextRound && game.botState.readyForNextRound) { %>
						<span class = "bothDone" [x]></span>
					<% } %>

				<% } %>

				</p>

			<% }) %>
		''')(games:games)

exports.setup = (games) ->
	$('#currentGames').html(currentGamesDiv(games))