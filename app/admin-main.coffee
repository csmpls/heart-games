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
		turn: 'entrust'
		points: 5
	}

	, 2: {
		turn: 'cooperateDefect'
		decision:'cooperate'
		points: 10
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
				<p>subject: <%= game.subject_id %></p>
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
		# clicking the div
		# will emit the api call in the div
		$('#' + key).asEventStream('click')
			.onValue( () -> 
				socket.emit('admin', apiCalls[key])))

		# socket.emit('new userlist', { my: 'data' }))

	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init())







