
_ = require 'lodash'
$ = require 'jquery'
baconModel = require 'bacon.model'
bacon$ = require 'bacon.jquery'
Bacon = require 'baconjs'

entrustView = () ->
	_.template('''
		<p>how many points would you like to entrust to your partner?</p>

		<textarea id="pointsToEntrust"></textarea>

		<br>

		<button id="entrustButton">Entrust</button>

		<button id="entrustNothingButton">Entrust nothing</button>
		''')()

setup = () ->

	# put view html in #content 
	$('#content').html(entrustView())

	# listen to text area
	pointsToEntrust = bacon$.textFieldValue($('#pointsToEntrust'))	

	# TODO validate text area (# btwn max/min)

	# streams of the two buttons
	entrust = $('#entrustButton').asEventStream('click')
	entrustNothing = $('#entrustNothingButton').asEventStream('click')

	# merge button streams into decision
	decision = entrust.map('entrust').merge(
		entrustNothing.map('entrustNothing')).toProperty()

	# create a stream of entrust turns
	# these are objects we can send as json to the server
	entrustTurns = Bacon.combineTemplate({
		decision: decision
		pointsEntrusted: pointsToEntrust
	}).sampledBy(decision)

	# return a stream of entrust turns 
	# (turns taken when user presses a button)
	entrustTurns



exports.setup = setup 
