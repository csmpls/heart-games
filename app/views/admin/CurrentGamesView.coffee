
_ = require 'lodash'
$ = require 'jquery'

# takes object of currently connected people
# returns div of currently connected people
currentGamesDiv = (games) ->
	_.template('''
			<% _.forEach(games, function(game) { %>
				<p>subject <%= game.subject_id %> 
				<% if (game.subject_is_connected) { %> 
					[connected]
				<% } %>

				<p>
				current turn: <%= game.currentTurn %>
				round: <%= game.round_num%>
				</p>

				<p> BOT: (bank: <%= game.botState.bank %>) <br>
				entrust: <%= game.botState.entrustTurn %><br>
				cooperate: <%= game.botState.cooperateDefectTurn%><br>
				ready: <%= game.botState.readyForNextRound %><br>

				<p> HUMAN: (bank: <%= game.botState.bank %>) <br>
				entrust: <%= game.humanState.entrustTurn %><br>
				cooperate: <%= game.humanState.cooperateDefectTurn %><br>
				ready: <%= game.humanState.readyForNextRound %><br>

			<% }) %>
		''')(games:games)

exports.setup = (games) ->
	$('#currentGames').html(currentGamesDiv(games))