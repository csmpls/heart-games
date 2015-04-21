$ = require 'jquery'
_ = require 'lodash'
io = require './lib/socket.io.js'
# Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconmodel = require 'bacon.model'

currentGamesView = require './views/admin/CurrentGamesView.coffee'
apiCallMakerView = require './views/admin/APICallMakerView.coffee'

# ---- config
socketURL = 'http://trust.coolworld.me/admin'
people = {} # currently connected people - no one's here, for now


apiCalls =  {

	1: {
		route: 'startGame'
		data: 
			null
	},

	2: {
		route: 'okToAdvance'
		data: 
			null
	},
}


# ---- application
init = ->

	socket = io(socketURL)

	# server tells us about the state of all games
	socket.on('games', (games) ->
		currentGamesView.setup(games))

	apiCallMakerView.setup(apiCalls, socket)

	# socket.emit('new userlist', { my: 'data' }))

	console.log 'admin app launched ok'


# ---- application
init = ->

	socket = io(socketURL)

	# server tells us about the state of all games
	socket.on('games', (games) ->
		currentGamesView.setup(games))

	apiCallMakerView.setup(apiCalls, socket)

	# socket.emit('new userlist', { my: 'data' }))

	console.log 'admin app launched ok'

# launch the app
$(document).ready(() ->
	init())