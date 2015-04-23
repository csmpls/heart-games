
randomInRange = require 'random-number-in-range'
config = require('./config.coffee')


giveOrTake = (value, amount, lowerBound, upperBound) ->
	result = value + randomInRange(-1*amount, amount+1)
	if result < lowerBound
		return lowerBound
	if result > upperBound
		return upperBound
	return result

##
## probability-based decisions
##
getEntrustDecision = (lastRound) -> 
	# always entrust
	return 'entrust'

getPointsEntrusted = (lastRound) -> 
	# if this is the first round
	if not lastRound
		# enturst 1
		return 1
	# otherwise
	#, do whatever the player did last time,
	# give or take 1 point
	pointsToEntrust = giveOrTake(lastRound.entrustTurn.pointsEntrusted, 1, 0, config.game.POINTS_ON_NEW_ROUND)
	return pointsToEntrust

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
		config.globalBotConfig.ENTRUST_TURN_TIME_MIN
		, config.globalBotConfig.ENTRUST_TURN_TIME_MAX )
getCooperateDefectDelay = -> 
	randomInRange(
		config.globalBotConfig.COOPERATE_DEFECT_TURN_TIME_MIN
		, config.globalBotConfig.COOPERATE_DEFECT_TURN_TIME_MAX )
getReadyDelay = -> 
	randomInRange(
		config.globalBotConfig.READY_NEXT_ROUND_TIME_MIN 
		, config.globalBotConfig.READY_NEXT_ROUND_TIME_MAX )


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
