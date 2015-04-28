
$ = require 'jquery'
_ = require 'lodash'
Bacon = require 'baconjs'
Bacon$ = require 'bacon.jquery'
BaconModel = require 'bacon.model'
randomInRange = require 'random-number-in-range'

generateHeartrateGraph = require '../../lib/GenerateHeartrateGraph.coffee'

delay = (delay, fn) -> setTimeout(fn,delay)

placeFingerOnHeartrateMonitorView = ->
	_.template('''
		<div class="summary">
			<h2>Please place your finger on the heartrate monitor.</h2>
			<p><small>To assure a good reading, keep your finger still, and don't press too hard on the monitor.</small></p>
			<p>Press next after you've placed your finger on the monitor.</p>
			<button id="seeSummaryView">Next</button>
		</div>
		''')

# TODO update bank 
roundSummaryView = (summary) ->
	_.template('''
		<div class="summary">
			<h2> Please keep your finger on the heartrate monitor. </h2>
			<div id = "roundSummary">
				<%= summary %> </p>
			</div>
			<p>Click next when you're ready.</p>
		<button id = "seeHeartrateView">Next</button>
		</div>
		''')(
		summary: summary)

calculatingPartnerHeartrateView = ->
	_.template('''
		<div class="summary">
		<h2> You can take your finger off the heartrate monitor.</h2>
		<p> Calculating your partner's heartrate...</p>
		<center><img src="assets/spinner.gif"></center>
		</div>
		''')

partnerHeartrateView = (summary) ->
	_.template('''
	<div class = "summary" id = "heartrateSummary">
		<div id = "graphContainer"> </div>
	</div>

	<button id = "readyButton">OK</button>
	''')(summary:summary)


setContent = ($contentDiv, html) ->
	$contentDiv.html(html)

exports.setup = (roundSummary) ->

	$content = $('#content')
	delayToShowHeartrate = randomInRange(4500,6700)

	readyForNextRound = new Bacon.Bus()

	# show them a notice to put their finger on heartrate monitor
	setContent($content, placeFingerOnHeartrateMonitorView())

	# when they click next,
	$('#seeSummaryView').asEventStream('click').onValue(() ->
		# load summary into the view
		setContent($content, roundSummaryView(roundSummary.summary))

		# when they click next on this screen, 
		$('#seeHeartrateView').asEventStream('click').onValue(()->
			# tell them we're preparing their partner's heartrate
			setContent($content, calculatingPartnerHeartrateView)
			# after some delay,
			# show them their partner's heartrate
			delay(delayToShowHeartrate, () -> 
				# add heartrate to the view
				setContent($content, partnerHeartrateView)
				hr = roundSummary.opponentHeartrate
				generateHeartrateGraph(
					hr.mean
					, hr.std
					, hr.interpretation
					, 'graphContainer')

				readyButtonClicks = $('#readyButton')
					.asEventStream('click')
					.onValue(()->readyForNextRound.push(1)))))

	# a stream of clicks on the 'ready' button
	readyForNextRound
