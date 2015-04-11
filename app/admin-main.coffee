$ = require 'jquery'
_ = require 'lodash'
io = require './lib/socket.io.js'
# Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconmodel = require 'bacon.model'

currentGamesView = require './views/admin/CurrentGamesView.coffee'
apiCallMakerView = require './views/admin/APICallMakerView.coffee'

# ---- config
port = 3000
people = {} # currently connected people - no one's here, for now
# apiCalls =  {

# 	1: {
# 		route: 'opponentReadyForNextRound'
# 		data: null 
# 	}

# 	, 2: {
# 		route: 'opponentEntrustTurn'
# 		data:
# 			decision:'cooperate'
# 			pointsEntrusted: 5
# 	}

# 	, 3: {
# 		route: 'roundSummary'
# 		data:
# 			summary: 'You entrusted your partner with 3 points. Your partner entrusted you with 5 points. Your partner cooperated with you, giving you 6 points.'
# 			bank: 10
# 	}
# }

apiCalls =  {

	1: {
		route: 'botReadyForNextRound'
		data: 
			subject_id: 1 
	},

	2: {
		route: 'botEntrustTurn'
		data: 
			subject_id: 1 
	},

	3: {
		route: 'botCooperateDefectTurn'
		data: 
			subject_id: 1 
	}
}


# ---- application
init = ->

	socket = io('http://localhost:' + port + '/admin')

	# server tells us about the state of all games
	socket.on('games', (games) ->
		currentGamesView.setup(games))

	apiCallMakerView.setup(apiCalls, socket)

	# socket.emit('new userlist', { my: 'data' }))

	console.log 'admin app launched ok'

# 	, 2: {
# 		route: 'opponentEntrustTurn'
# 		data:
# 			decision:'cooperate'
# 			pointsEntrusted: 5
# 	}

# 	, 3: {
# 		route: 'roundSummary'
# 		data:
# 			summary: 'You entrusted your partner with 3 points. Your partner entrusted you with 5 points. Your partner cooperated with you, giving you 6 points.'
# 			bank: 10
# 	}
# }

# ---- application
init = ->

	socket = io('http://localhost:' + port + '/admin')

	# server tells us about the state of all games
	socket.on('games', (games) ->
		currentGamesView.setup(games))

	apiCallMakerView.setup(apiCalls, socket)

	# socket.emit('new userlist', { my: 'data' }))

	console.log 'admin app launched ok'

# launch the app
$(document).ready(() ->
	init())