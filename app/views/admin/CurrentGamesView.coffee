
_ = require 'lodash'
$ = require 'jquery'

# takes object of currently connected people
# returns div of currently connected people
currentGamesDiv = (games) ->
	_.template('''
			<% _.forEach(games, function(game) { %>
				<p>subject: <%= game.subject_id %> 
				- connected? <%= game.subject_is_connected %> </p>
			<% }) %>
		''')(games:games)

exports.setup = (games) ->
	$('#currentGames').html(currentGamesDiv(games))