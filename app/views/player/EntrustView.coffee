
_ = require 'lodash'
$ = require 'jquery'
baconModel = require 'bacon.model'
bacon$ = require 'bacon.jquery'
Bacon = require 'baconjs'

setEnabled = (element, enabled) -> element.attr("disabled", !enabled) 

entrustView = () ->
	_.template('''
		<p>how many points would you like to entrust to your partner?</p>

		<div id = "pointsToEntrustPanel">
			<button id = "entrustLess">-</button>
			<div id="pointsToEntrustDiv"> 0 </div>
			<button id = "entrustMore">+</button>
		</div>

		<br>

		<button id="entrustButton">Entrust</button>

		<button id="entrustNothingButton">Entrust nothing</button>
		''')()

change = (points, changeDir, maxPoints) ->
	if changeDir == 'up' and points+1 <= maxPoints 
		points+=1
	else if changeDir == 'down' and points-1 >= 0
		points-=1
	return points

setup = (pointsThisRound) ->

	# put view html in #content 
	$('#content').html(entrustView())

	$entrustButton = $('#entrustButton')
	$entrustNothingButton = $('#entrustNothingButton')
	$pointsToEntrustDiv = $('#pointsToEntrustDiv')

	setEnabled($entrustButton,false)

	upButton = $('#entrustMore').asEventStream('click').map(1)
	downButton = $('#entrustLess').asEventStream('click').map(-1)

	# limit points to entrust to be wthin max points and 0 points
	pointsToEntrustProp = upButton.merge(downButton)
		.scan(0, (x,y) -> 
			val = x+y
			if val <= 0
				return 0
			if val > pointsThisRound
				return pointsThisRound
			else
				return val)

	# show pointsToEntrustProp on the $pointsToEntrustDiv
	pointsToEntrustProp.assign($pointsToEntrustDiv, 'text')

	# disable entrust button when pointsToEntrustProp == 0
	pointsToEntrustProp
		.map((points) -> if points > 0 then true else false)
		.assign(setEnabled, $entrustButton)

	# disable entrustNothing button when pointsToEntrustProp > 0
	pointsToEntrustProp
		.map((points) -> if points > 0 then false else true)
		.assign(setEnabled, $entrustNothingButton)


	# streams of the two buttons
	entrust = $entrustButton.asEventStream('click')
	entrustNothing = $entrustNothingButton.asEventStream('click')

	# these are objects we can send as json to the server
	entrustTurns = Bacon.combineTemplate({
		decision: 'entrust'
		pointsEntrusted: pointsToEntrustProp
	}).sampledBy(entrust)

	# create another stream of entrustNothing turns
	entrustNothingTurns = Bacon.combineTemplate({
		decision: 'entrustNothing'
		pointsEntrusted: 0
	}).sampledBy(entrustNothing)

	turns = entrustNothingTurns.merge(entrustTurns)

	# return a stream of turns 
	turns



exports.setup = setup 
