_ = require 'lodash'

playerBot = require './playerBot.coffee'

# returns true if both turns have been played
bothTurnsPlayed = (turn1, turn2) -> if turn1 and turn2 then true else false

# takes object data: {subject_id, station_num, humanBank, botBank}
# returns an object representing a round
initializeNewGame = (data) ->
	return { 
		# save the socket
		subject_id: data.subject_id
		station_num: data.station_num
		subject_is_connected: true
		round_num: 0
		currentTurn: null
		# make them a bot to play against
		bot: playerBot
		# bot game state
		botState: getFreshActorState(0)
		# human game state 
		humanState: getFreshActorState(0) }

# the state of an actor (on new round)
getFreshActorState = (bankAmount) ->
	return { 
		entrustTurn: null
		cooperateDefectTurn: null
		readyForNextRound: null
		bank: bankAmount }

# actor's earnings from a round
getRoundEarnings = (actorState, opponentState) ->
	# if opponent defected:
	if opponentState.cooperateDefectTurn.decision == 'defect'
		# subtract amount actor entrusted to opponent
		return -actorState.entrustTurn.pointsEntrusted
	# if opponent cooperated,
	# double amount actor entrusted to opponent
	return 2*actorState.entrustTurn.pointsEntrusted

# function takes a round
# returns an object {botBank, humanBank}
getBankAmounts = (round) ->
	return {
		botBank: round.botState.bank + getRoundEarnings(round.botState, round.humanState), 
		humanBank: round.humanState.bank + getRoundEarnings(round.humanState, round.botState) }

entrustTurnSummary = (subject, pointsEntrusted, directObject) ->
	if pointsEntrusted == 0
		pointsEntrusted = 'nothing'
	else:
		pointsEntrusted += ' points'
	_.template('<%=subject%> entrusted <%=pointsEntrusted%> to <%=directObject%>. ')(
		subject: subject
		pointsEntrusted: pointsEntrusted
		directObject: directObject)

cooperateDefectTurnSummary = (subject, decision, directObject) ->
	if decision == 'cooperate'
		decision = 'returned'
	else
		decision = 'kept'
	return _.template('<%=subject%> <%=decision%> the points <%=directObject%> entrusted. ')(
		subject: subject
		decision: decision
		directObject: directObject)

roundEarningsSummary = (earnings) ->
	_.template('<%= earnings %> points have been added to your bank. ')(earnings:earnings)

getHumanSummary = (humanState, botState) ->
	return '<p>' + entrustTurnSummary('You', humanState.entrustTurn.pointsEntrusted, 'your partner', ) + 
	cooperateDefectTurnSummary('Your partner', botState.cooperateDefectTurn.decision, 'you') + '</p>' +

	'<p>' + entrustTurnSummary('Your partner', botState.entrustTurn.pointsEntrusted, 'you', ) + 
	cooperateDefectTurnSummary('You', humanState.cooperateDefectTurn.decision, 'your partner') + '</p>' +	

	'<p>' + roundEarningsSummary(getRoundEarnings(humanState, botState)) + '</p>'



# resets the round 
# + iterates round_num
# TODO: calculate bank amounts
nextRound = (round, banks) ->
	round.currentTurn = null
	round.botState = getFreshActorState(banks.botBank)
	round.humanState = getFreshActorState(banks.humanBank)
	round.round_num = round.round_num+1

# this function checks if a round is done
# if it is, it
# (1) tells the human about the bot's move
# (2) starts the bot on playing its next move
checkRoundCompletion = (round, emitToSubject, pushGamesToAdmins) ->

	# entrust turn
	if round.currentTurn == 'entrustTurn'
		humanTurn = round.humanState.entrustTurn
		botTurn = round.botState.entrustTurn
		clientMessage = 'opponentEntrustTurn'
		clientPayload = botTurn
		nextTurn = 'cooperateDefectTurn'
		nextBotTurnFn = round.bot.playCooperateDefectTurn

	# c or d turn
	if round.currentTurn == 'cooperateDefectTurn'
		humanTurn = round.humanState.cooperateDefectTurn
		botTurn = round.botState.cooperateDefectTurn
		clientMessage = 'roundSummary'
		nextTurn = 'readyForNextRound'
		nextBotTurnFn = round.bot.playReadyForNextRound

	# ready for next round message
	if round.currentTurn == 'readyForNextRound'
		humanTurn = round.humanState.readyForNextRound
		botTurn = round.botState.readyForNextRound
		clientMessage = 'opponentReadyForNextRound'
		clientPayload = true
		nextTurn = 'entrustTurn'
		nextBotTurnFn = round.bot.playEntrustTurn

	if bothTurnsPlayed(humanTurn, botTurn)

		# if round is cooperateDefectRound
		if round.currentTurn == 'cooperateDefectTurn'
		# we get the turn summary for the (human) player
			clientPayload = 
				{summary: getHumanSummary(round.humanState, round.botState)
				, bank: getBankAmounts(round).humanBank}

		# if next round is 'readyForNextRound',
		# its time to save our data + reset
		if round.currentTurn  == 'readyForNextRound'
			# TODO save turn data here
			banks = getBankAmounts(round)
			# start next round
			nextRound(round, banks)

		# emit bot's turn to human
		emitToSubject(round.subject_id, clientMessage, clientPayload)
		# start bot going on next turn
		nextBotTurnFn(round, emitToSubject, pushGamesToAdmins, checkRoundCompletion)
		# set round to the next round
		round.currentTurn = nextTurn
		# update admins
		pushGamesToAdmins()



exports.initializeNewGame = initializeNewGame
exports.checkRoundCompletion = checkRoundCompletion