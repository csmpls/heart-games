
playerBot = require './playerBot.coffee'

# returns true if both turns have been played
bothTurnsPlayed = (turn1, turn2) -> if turn1 and turn2 then true else false

# function takes a round
# returns an object {humanBank, botBank}
getBankAmounts = (round) ->
	botBank = round.botState.bank + 1
	humanBank = round.humanState.bank + 2
	return {botBank: botBank, humanBank: humanBank}

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
		humanState: getFreshActorState(0)
	}

# the state of an actor (on new round)
getFreshActorState = (bank) ->
	return { 
		entrustTurn: null
		cooperateDefectTurn: null
		readyForNextRound: null
		bank: bank
	}

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
		# TODO
		clientPayload = {summary: 'this is a test summary for now.', bank:10}
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

		# if next round is 'readyForNextRound',
		# its time to save our data + reset
		if round.currentTurn  == 'readyForNextRound'
			# TODO save turn data here
			# reset round data 
			nextRound(round
				# calculate bank amounts for both parties
				, getBankAmounts(round))

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