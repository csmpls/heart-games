
_ = require 'lodash'
$ = require 'jquery'

# takes object of currently connected people
# returns div of currently connected people

##  [connectedMarker] subject [userId] (station [num], [elevatedCondition])
##  human (bank n)  /  bot (bank n) 
##  round [round]: [currentTurn]
##  [x] - [waiting..]
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

				human (<%= game.botState.bank %>)
				/
				bot ( <%= game.botState.bank %>)
				</small>

				<br>

				<b><i>
				round <%= game.round_num %>: 
				<%= game.currentTurn %>
				</b></i>

				<br>

				<% if (game.currentTurn == 'entrustTurn') { %>

					<% if (game.humanState.entrustTurn) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

					<% if (game.botState.entrustTurn) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'cooperateDefectTurn') { %>

					<% if (game.humanState.cooperateDefectTurn) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

					<% if (game.botState.cooperateDefectTurn) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

				<% } %>

				<% if (game.currentTurn == 'readyForNextRound') { %>

					<% if (game.humanState.readyForNextRound) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

					<% if (game.botState.readyForNextRound) { %>
						[x]
					<% } else { %>
						[waiting..]
					<% } %>

				<% } %>

				</p>

			<% }) %>
		''')(games:games)

exports.setup = (games) ->
	$('#currentGames').html(currentGamesDiv(games))