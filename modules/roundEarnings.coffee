
#
#  earnings/bank calculations
#

config = require './config.coffee'

# we add # points opponent returned 
# (or subtract # of points opponent stole)
pointsFromEntrusting = (actorState, opponentState) ->
	# if opponent defected:
	if opponentState.cooperateDefectTurn.decision == 'defect'
		# subtract amount actor entrusted to opponent
		return -actorState.entrustTurn.pointsEntrusted
	# if opponent cooperated,
	# double amount actor entrusted to opponent
	return 2*actorState.entrustTurn.pointsEntrusted

pointsFromTaking = (actorState, opponentState) ->
	# if we took points
	if actorState.cooperateDefectTurn.decision == 'defect'
		return opponentState.entrustTurn.pointsEntrusted
	return 0

# actor's earnings from a round
getRoundEarnings = (actorState, opponentState) ->
	# what the subject hasn't yet spent this round
	pointsLeftThisRound = config.game.POINTS_ON_NEW_ROUND - actorState.entrustTurn.pointsEntrusted
	# what the subject hasn't yet spent + what the subject got (or lost) from entrusting decision + what the user got from taking, if they took
	return pointsFromEntrusting(actorState, opponentState) + pointsFromTaking(actorState, opponentState) + pointsLeftThisRound


# function takes a round
# returns an object {botBank, humanBank}
getBankAmounts = (round) ->
	return {
		botBank: round.botState.bank + getRoundEarnings(round.botState, round.humanState), 
		humanBank: round.humanState.bank + getRoundEarnings(round.humanState, round.botState) 
	}


exports.getRoundEarnings = getRoundEarnings
exports.getBankAmounts = getBankAmounts
