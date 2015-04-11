
getEntrustDecision = -> return 'entrust'
getPointsEntrusted = () -> return 3
getCooperateDefectDecision = -> return 'defect'

getEntrustDelay = -> return 100
getCooperateDefectDelay = -> return 1000
getReadyDelay = -> return 1000

# TODO 
# this takes a config object
module.exports = 

	playEntrustTurn: (round)-> 
		round.botState.entrustTurn = {decision: getEntrustDecision(), pointsEntrusted: getPointsEntrusted()}
		round

	playCooperateDefectTurn: (round) -> 
		round.botState.cooperateDefectTurn = {decision: getCooperateDefectDecision()}
		round

	playReadyForNextRound: (round) -> 
		round.botState.readyForNextRound = true
		round

	getTimeoutDelay:  (turn) -> 
		if turn == 'entrustTurn' 
			return getEntrustDelay()

		if turn == 'cooperateDefectTurn'
			return getCooperateDefectDelay()

		if turn == 'readyForNextRound'
			return getReadyDelay()
