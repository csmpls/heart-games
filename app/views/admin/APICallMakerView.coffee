
_ = require 'lodash'
$ = require 'jquery'
stringifyObject = require 'stringify-object'

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

exports.setup = (apiCalls, socket) ->
	# setup API call buttons
	_.forEach(apiCalls, (call, key) ->
		# add a div for each API call
		callMakerDiv = callMaker(call, key)
		$('#callMakers').append(callMakerDiv)
		# clicking a div will emit its api call 
		$('#' + key).asEventStream('click')
			.onValue(() -> 
				socket.emit(apiCalls[key].route, apiCalls[key].data)))