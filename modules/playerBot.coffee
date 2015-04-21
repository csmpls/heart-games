
randomInRange = require 'random-number-in-range'
globalBotConfig = require('./config.coffee').globalBotConfig

##
## probability-based decisions
##
getEntrustDecision = (lastRound) -> 
	# if this is the first round
	if not lastRound
		# entrust
		return 'entrust'
	# otherwise,
	# do whatever the opponent did last time
	return lastRound.entrustTurn.decision

getPointsEntrusted = (lastRound) -> 
	# if this is the first round
	if not lastRound
		# enturst 1
		return 1
	# otherwise
	#, do whatever the player did last time
	return lastRound.entrustTurn.pointsEntrusted

getCooperateDefectDecision = (lastRound) -> 
	# if this is the first round
	if not lastRound
		# cooperate
		return 'cooperate'
	# otherwise,
	# do whatever the opponent did last time
	return lastRound.cooperateDefectTurn.decision

getEntrustDelay = -> 
	randomInRange(
		globalBotConfig.ENTRUST_TURN_TIME_MIN
		, globalBotConfig.ENTRUST_TURN_TIME_MAX )
getCooperateDefectDelay = -> 
	randomInRange(
		globalBotConfig.COOPERATE_DEFECT_TURN_TIME_MIN
		, globalBotConfig.COOPERATE_DEFECT_TURN_TIME_MAX )
getReadyDelay = -> 
	randomInRange(
		globalBotConfig.READY_NEXT_ROUND_TIME_MIN 
		, globalBotConfig.READY_NEXT_ROUND_TIME_MAX )


##
## lower-level playing functions
## 
delay = (ms, func) -> setTimeout func, ms

generateEntrustTurn = (round, lastRound)-> 
	round.botState.entrustTurn = {
		decision: getEntrustDecision(lastRound)
		pointsEntrusted: getPointsEntrusted(lastRound) }
	round

generateCooperateDefectTurn = (round, lastRound) -> 
	round.botState.cooperateDefectTurn = {
		decision: getCooperateDefectDecision(lastRound) }
	round

generateReadyForNextRound = (round, lastRound) -> 
	round.botState.readyForNextRound = true
	round

getTimeoutDelay = (turn) -> 
	if turn == 'entrustTurn' 
		return getEntrustDelay()

	if turn == 'cooperateDefectTurn'
		return getCooperateDefectDelay()

	if turn == 'readyForNextRound'
		return getReadyDelay()

module.exports = 


	# the bot stores the last round it saw
	# it uses this to pick its decision for the next round
	humanStateLastRound: null

	playEntrustTurn: (round, lastRound, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('entrustTurn')
			, () -> 
				round = generateEntrustTurn(round,lastRound)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))

	playCooperateDefectTurn: (round, lastRound, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('cooperateDefectTurncooperate')
			, () -> 
				round = generateCooperateDefectTurn(round,lastRound)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))

	playReadyForNextRound: (round, lastRound, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('readyForNextRound')
			, () -> 
				round = generateReadyForNextRound(round,lastRound)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))