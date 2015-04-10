$ = require 'jquery'
_ = require 'lodash'
io = require './lib/socket.io.js'
# Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconmodel = require 'bacon.model'
stringifyObject = require 'stringify-object'

# ---- config
port = 3000
people = {} # currently connected people - no one's here, for now
apiCalls =  {

	1: {
		route: 'opponentReadyForNextRound'
		data: null 
	}

	, 2: {
		route: 'opponentEntrustTurn'
		data:
			decision:'cooperate'
			pointsEntrusted: 5
	}

	, 3: {
		route: 'turnSummary'
		data:
			summary: 'You entrusted your partner with 3 points. Your partner entrusted you with 5 points. Your partner cooperated with you, giving you 6 points.'
			bank: 10
	}
}


# ---- views

# takes an object
# returns a div with that object in it
callMaker = (call, id) ->
	_.template('''
		<div class = "callMaker" id = "<%= id %>">
			<%= call %>
		</div>
		''')(
		call:stringifyObject(call)
		id: id
		)

# takes object of currently connected people
# returns div of currently connected people
currentGamesDiv = (games) ->
	_.template('''
			<% _.forEach(games, function(game) { %>
				<p>subject: <%= game.subject_id %> 
				- connected? <%= game.subject_is_connected %> </p>
			<% }) %>
		''')(games:games)


# ---- application
init = ->

	socket = io('http://localhost:' + port + '/admin')

	console.log 'main app launching'

	# server tells us about the state of all games
	socket.on('games', (games) ->
		$('#currentGames').html(currentGamesDiv(games)))


	# setup API call buttons
	_.forEach(apiCalls, (call, key) ->
		# add a div for each API call
		callMakerDiv = callMaker(call, key)
		$('#callMakers').append(callMakerDiv)
		# clicking a div will emit its api call 
		$('#' + key).asEventStream('click')
			.onValue( () -> 
				socket.emit(apiCalls[key].route, apiCalls[key].data)))

		# socket.emit('new userlist', { my: 'data' }))

	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init())







