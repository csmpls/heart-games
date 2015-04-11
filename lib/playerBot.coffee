
getEntrustDecision = -> return 'entrust'
getPointsEntrusted = () -> return 3
getCooperateDefectDecision = -> return 'defect'

getEntrustDelay = -> return 100
getCooperateDefectDelay = -> return 1000
getReadyDelay = -> return 1000

# setTimeout helper function
# puts callback last
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