$ = require 'jquery'
_ = require 'lodash'

waitingView = (waitingForMessage) ->
	_.template('''
		<h3>waiting for <%= waitingForMessage %>...</h3
		''')(waitingForMessage: waitingForMessage)

waitingFor = (waitingForMessage) ->
	$('#content').html(waitingView(waitingForMessage))

exports.waitingFor = waitingFor