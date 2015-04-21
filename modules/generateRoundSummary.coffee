_ = require 'lodash'


entrustTurnSummary = (subject, pointsEntrusted, directObject) ->
	if not pointsEntrusted
		pointsEntrusted = 'nothing'

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


generateRoundSummary = (round, roundEarnings) ->

	humanState = round.humanState
	botState = round.botState

	return '<p>' + entrustTurnSummary('You', humanState.entrustTurn.pointsEntrusted, 'your partner', ) +
	cooperateDefectTurnSummary('Your partner', botState.cooperateDefectTurn.decision, 'you') + '</p>' +

	'<p>' + entrustTurnSummary('Your partner', botState.entrustTurn.pointsEntrusted, 'you', ) +
	cooperateDefectTurnSummary('You', humanState.cooperateDefectTurn.decision, 'your partner') + '</p>' +

	'<p>' + roundEarningsSummary(roundEarnings) + '</p>' 

module.exports = generateRoundSummary