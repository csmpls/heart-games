example_view = require './lib/view.coffee'
$ = require 'jquery'
io = require './lib/socket.io.js'

init = ->

	port = 3000

	console.log 'main app launching'
	# example_view.setup()

	$('body').append('yoooo')

	socket = io.connect('http://localhost:' + port)
	socket.on('news', (data) ->
		console.log(data);
		socket.emit('my other event', { my: 'data' }))

	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init())
