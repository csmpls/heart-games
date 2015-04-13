
randomInRange = require 'random-number-in-range'
globalBotConfig = require('./config.coffee').globalBotConfig

##
## probability-based decisions
##
getEntrustDecision = -> return 'entrust'
getPointsEntrusted = () -> return 3
getCooperateDefectDecision = -> return 'cooperate'

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

generateEntrustTurn = (round)-> 
	round.botState.entrustTurn = {decision: getEntrustDecision(), pointsEntrusted: getPointsEntrusted()}
	round

generateCooperateDefectTurn = (round) -> 
	round.botState.cooperateDefectTurn = {decision: getCooperateDefectDecision()}
	round

generateReadyForNextRound = (round) -> 
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

	playEntrustTurn: (round, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('entrustTurn')
			, () -> 
				round = generateEntrustTurn(round)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))

	playCooperateDefectTurn: (round, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('cooperateDefectTurncooperate')
			, () -> 
				round = generateCooperateDefectTurn(round)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))

	playReadyForNextRound: (round, emitToSubject, pushGamesToAdmins, checkRoundCompletion) ->
		delay(getTimeoutDelay('readyForNextRound')
			, () -> 
				round = generateReadyForNextRound(round)
				pushGamesToAdmins()
				checkRoundCompletion(round, emitToSubject, pushGamesToAdmins))