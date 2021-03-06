_ = require 'lodash'
playerBot = require './playerBot.coffee'
generateBotHeartrate = require './generateBotHeartrate.coffee'
generateRoundSummary = require './generateRoundSummary.coffee'
saveTrustGameRound = require './saveTrustGameRound.coffee'
roundEarnings = require './roundEarnings.coffee'
config = require './config.coffee'


#
# get turn data
#

# returns true if both turns have been played
bothTurnsPlayed = (turn1, turn2) -> if turn1 and turn2 then true else false

# returns {botTurn, humanTurn}
getEntrustTurns = (round) ->
	return {
		botTurn: round.botState.entrustTurn
		, humanTurn: round.humanState.entrustTurn }

# returns {botTurn, humanTurn}
getCooperateDefectTurns = (round) ->
	return {
		humanTurn: round.humanState.cooperateDefectTurn
		botTurn: round.botState.cooperateDefectTurn }

# returns {botTurn, humanTurn}
getReadyForNextRoundTurns = (round) ->
	return { 
		humanTurn: round.humanState.readyForNextRound
		botTurn: round.botState.readyForNextRound }



#
#  round state stuff
#

# takes object data: {subject_id, station_num, humanBank, botBank}
# returns an object representing a round
initializeNewGame = (data) ->
	return { 
		# save the socket
		subject_id: data.subject_id
		station_num: data.station_num
		elevated_heartrate_condition: data.elevated_heartrate_condition
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

# resets the round 
# + iterates round_num
# TODO: calculate bank amounts
setNextRoundState = (round, banks) ->
	round.currentTurn = null
	round.botState = getFreshActorState(banks.botBank)
	round.humanState = getFreshActorState(banks.humanBank)
	round.round_num = round.round_num+1




#
#  manage the flow of turns
#

# this function checks if a round is done
# if it is, it
# (1) tells the human about the bot's move
# (2) starts the bot on playing its next move
checkRoundCompletion = (round, emitToSubject, pushGamesToAdmins) ->

	# entrust turn
	if round.currentTurn == 'entrustTurn'
		turns = getEntrustTurns(round)
		startNextTurnFn = startCooperateDefectTurn 

	# c or d turn
	if round.currentTurn == 'cooperateDefectTurn'
		turns = getCooperateDefectTurns(round)
		startNextTurnFn = startReadyForNextRoundTurn

	# ready for next round message
	if round.currentTurn == 'readyForNextRound'
		turns = getReadyForNextRoundTurns(round)	
		startNextTurnFn = startEntrustTurn

	# if both turns have been played, 
	if bothTurnsPlayed(turns.humanTurn, turns.botTurn)
		# store the 'start next turn' fn 
		# so that the game can launch it
		# when the admin says to
		round.startNextTurnFn = () -> startNextTurnFn(round, emitToSubject, pushGamesToAdmins)

	# start the next turn
		# startNextRoundFn(round, emitToSubject, pushGamesToAdmins)
			

startEntrustTurn = (round, emitToSubject, pushGamesToAdmins) ->

	# store the user's moves this round with the bot
	# the bot uses the user's moves this round to make decisions next round
	round.bot.humanStateLastRound = round.humanState

	# reset round state
	banks = roundEarnings.getBankAmounts(round)
	setNextRoundState(round, banks)

	# send the client the points they can use during the next round
	clientMessage = 'startEntrustTurn'
	clientPayload = {points: config.game.POINTS_ON_NEW_ROUND}
	nextTurn = 'entrustTurn'
	nextBotTurnFn = round.bot.playEntrustTurn

	console.log 'reached, entrust'

	startTurn(round, clientMessage, clientPayload, nextTurn, nextBotTurnFn, emitToSubject, pushGamesToAdmins)


startCooperateDefectTurn = (round, emitToSubject, pushGamesToAdmins) ->
	# we send the client the bot's entrust turn
	clientMessage = 'startCooperateDefectTurn'
	clientPayload = getEntrustTurns(round).botTurn
	nextTurn = 'cooperateDefectTurn'
	nextBotTurnFn = round.bot.playCooperateDefectTurn

	console.log 'reached, cooperate defect'

	startTurn(round, clientMessage, clientPayload, nextTurn, nextBotTurnFn, emitToSubject, pushGamesToAdmins)


startReadyForNextRoundTurn = (round, emitToSubject, pushGamesToAdmins) ->

	# save round data to a postgres database
	saveTrustGameRound.saveTrustGameRound(round)


	# we send the client a summary of the round
	clientMessage = 'roundSummary'
	nextTurn = 'readyForNextRound'
	nextBotTurnFn = round.bot.playReadyForNextRound
	clientPayload = 
				{summary: generateRoundSummary(round, roundEarnings.getRoundEarnings(round.humanState, round.botState))
				, bank: roundEarnings.getBankAmounts(round).humanBank
				opponentHeartrate: generateBotHeartrate(round.humanState, round.elevated_heartrate_condition) }

	console.log 'reached', clientPayload 

	startTurn(round, clientMessage, clientPayload, nextTurn, nextBotTurnFn, emitToSubject, pushGamesToAdmins)

startTurn = (round, clientMessage, clientPayload, nextTurn, nextBotTurnFn, emitToSubject, pushGamesToAdmins) ->
		# emit bot's turn to human
		emitToSubject(round.subject_id, clientMessage, clientPayload)
		# start bot going on next turn
		nextBotTurnFn(round, round.bot.humanStateLastRound, emitToSubject, pushGamesToAdmins, checkRoundCompletion)
		# set round to the next round
		round.currentTurn = nextTurn
		# update admins
		pushGamesToAdmins()



exports.initializeNewGame = initializeNewGame
exports.checkRoundCompletion = checkRoundCompletion
exports.startEntrustTurn = startEntrustTurn