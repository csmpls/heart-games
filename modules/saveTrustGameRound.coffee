Sequelize = require 'sequelize'
db_config = require './db_config.coffee'

# setup our db
sequelize = db_config()

TrustGameRound = sequelize.define('TrustGameRound', {
		id: Sequelize.INTEGER
		station_num: Sequelize.INTEGER
		round_num: Sequelize.INTEGER
		human_entrusted: Sequelize.INTEGER
		bot_entrusted: Sequelize.INTEGER
		human_cooperated: Sequelize.BOOLEAN
		bot_cooperated: Sequelize.BOOLEAN
		elevated_heartrate_condition: Sequelize.INTEGER
		human_bank: Sequelize.INTEGER
		bot_bank: Sequelize.INTEGER
	})

# make a sequlize model for a round
syncTrustGameRoundModel = () -> TrustGameRound.sync()

getPointsEntrusted = (state) -> Number(state.entrustTurn.pointsEntrusted)

getCooperateDecisionAsBoolean = (state) -> if state.cooperateDefectTurn.decision == 'cooperate' then true else false

saveTrustGameRound = (round) ->

	TrustGameRound.create({
		id: round.subject_id
		station_num: round.station_num
		round_num: round.round_num
		human_entrusted: getPointsEntrusted(round.humanState)
		bot_entrusted: getPointsEntrusted(round.botState)
		human_cooperated: getCooperateDecisionAsBoolean(round.humanState)
		bot_cooperated: getCooperateDecisionAsBoolean(round.botState)
		elevated_heartrate_condition: round.elevated_heartrate_condition
		human_bank: round.humanState.bank
		bot_bank: round.botState.bank
		})

exports.syncTrustGameRoundModel = syncTrustGameRoundModel
exports.saveTrustGameRound = saveTrustGameRound