example_view = require './lib/view.coffee'
$ = require 'jquery'
io = require './lib/socket.io.js'

init = ->

	port = 3000
	subject_id = 911
	station_num = 420 

	console.log 'main app launching'
	example_view.setup()

	socket = io('http://localhost:' + port + '/players')

	#login
	socket.emit('login', {
		subject_id:subject_id
		station_num: station_num })
	
	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init())
