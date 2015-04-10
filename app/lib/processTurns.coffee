
# these functions take a 'round' object
# 
# 	id: { 
# 		human:{bank, points, entrustTurn, cooperateDefectTurn, readyForNextRound}
# 		, computer:{..}
# 		, round
# 		, station
# 		, socket
# 	}
#
# which they update and return 

# sets readyForNextRound to true
processReadyForNextRound = (round, actor) ->

	# save the turn in the game state
	if actor == 'human'
		round.human.readyForNextRound = true 
	if actor == 'computer'
		round.computer.readyForNextRound = true 

	# if both turns are in, 
	if round.human.readyForNextRound and round.computer.readyForNextRound
		# emit the turn to the human
		round.socket.emit()

	# return the modified round
	round

# sets entrust turn
processEntrustTurn = (round, turn, actor) -> 

	# save the turn in the game state
	if actor == 'human'
		round.human.entrustTurn = turn
	if actor == 'computer'
		round.computer.entrustTurn = turn

	# if both turns are in, 
	if round.human.entrustTurn and round.computerentrustTurn
		# emit the turn to the human
		round.socket.emit(computer.entrustTurn)

	# return the modified round
	round

# sets cooperate/defect turn
# TODO calculates how many points to give to each player
# TODO update bank for each player
processCooperateDefectTurn = (round, turn, actor) -> 

	# save the turn in the game state
	if actor == 'human'
		round.human.cooperateDefectTurn = turn
	if actor == 'computer'
		round.computer.cooperateDefectTurn = turn

	# if both turns are in, 
	if round.human.cooperateDefectTurn and round.computer.cooperateDefectTurn
		# emit the round summary to the human
		round.socket.emit('turnSummary', generateRoundSummary(round))

	# return the modified round
	round

# TODO calculate amount in the bank
generateRoundSummary = (round) -> {summary: round, bank: -1}


exports.processReadyForNextRound = processReadyForNextRound
exports.processEntrustTurn = processEntrustTurn
exports.processCooperateDefectTurn = processCooperateDefectTurn