$ = require 'jquery'
_ = require 'lodash'
io = require './lib/socket.io.js'
Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconmodel = require 'bacon.model'

currentGamesView = require './views/admin/CurrentGamesView.coffee'
apiCallMakerView = require './views/admin/APICallMakerView.coffee'
advanceAllButton = require './views/admin/AdvanceAllButton.coffee'

# ---- config
socketURL = 'trust.coolworld.me/admin'
#socketURL = 'http://localhost:29087/admin'
people = {} # currently connected people - no one's here for now


apiCalls =  {

	1: {
		route: 'startGame'
		data: 
			null
	},

	2: {
		route: 'pushSurveyToAll'
		data:
			null
	}
}


init = ->

	socket = io(socketURL)

	# server tells us about the state of all games
	socket.on('games', (games) ->

		# this draws a button that lets us advance 
		# all the players at once
		# it only gets drawn when 
		# everyone is done with their turn
		if games then advanceAllButton.draw(socket, games)

		serverMessages = currentGamesView.setup(games)

		serverMessages.onValue((message) ->
			socket.emit(message.route, message.data)) )

	apiCallMakerView.setup(apiCalls, socket)

	console.log 'admin app launched ok'


# launch the app
$(document).ready(() -> init())