_ = require 'lodash'
$ = require 'jquery'
Bacon = require 'baconjs'
Bacon$ = require 'bacon.jquery'
BaconModel = require 'bacon.model'

nonEmpty = (thing) -> if thing.length > 0 then true else false
bothTrue = (thing1, thing2) -> if (thing1 and thing2) then true else false
setEnabled = (element, enabled) -> element.attr("disabled", !enabled) 

loginTemplate = ->
	_.template('''
		<h2>Please wait here for the experimenter's instructions.</h2>
		User ID: <input type="text" id="subjectIdInput"/>
		Station number:  <input type="text" id="stationNumInput"/>
		<button id = "loginButton">Log In</button>
		''')()

setup = ->

	$('#content').html(loginTemplate())

	$subjectIdInput = $("#subjectIdInput")
	$stationNumInput = $("#stationNumInput" )
	$loginButton = $("#loginButton")

	subjectId = Bacon$.textFieldValue($subjectIdInput)
	stationNum = Bacon$.textFieldValue($stationNumInput)
	loginButtonClicks = $loginButton.asEventStream('click')

	# disable the login button when either subjectId or stationNum is empty
	bothFieldsFilled = subjectId.map(nonEmpty)
		.combine(stationNum.map(nonEmpty), bothTrue)
	bothFieldsFilled.assign(setEnabled, $loginButton)

	# make a template of our data
	loginSubmissions = Bacon.combineTemplate({
		subject_id: subjectId 
		station_num: stationNum
	})

	# return a stream of login submissions
	# we get these whenever the login button is clicked.
	loginSubmissions.sampledBy(loginButtonClicks)


exports.setup = setup