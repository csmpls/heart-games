
randomInRange = require 'random-number-in-range'
heartrateConfig = require('./config.coffee').heartrateConditionConfig

###
-------------------------------------------
-----------------------------------
  generate    bot     heartrate
-----------------------------------
-------------------------------------------
###

generateBotHeartrate = (humanPlayerState, elevatedHeartrateCondition) ->

	didHumanScrewMeOver = humanPlayerState.cooperateDefectTurn.decision == 'defect'

	if didHumanScrewMeOver and elevatedHeartrateCondition
		# return an elevated heartrate
		return {
			mean: elevatedHeartrateMean()
			std: elevatedHeartrateStd()
			interpretation: elevatedHeartrateInterpretation() }

	# return a normal heartrate
	return {
		mean: normalHeartrateMean()
		std: normalHeartrateStd()
		interpretation: normalHeartrateInterpretation() }

###
given the last round (humanPlayerState), and the subject's condition (elevatedHeartrateCondition), this function generates the heartrate that the player sees after the round is over.

for starters, we just elevate the heartrate whenever player screws over the other player, assuming elevatedHeartrateCondition is true.

returns {mean, std, interpretation}

###

elevatedHeartrateMean = ->
	randomInRange(
		heartrateConfig.ELEVATED_HEARTRATE_MEAN_MIN
		, heartrateConfig.ELEVATED_HEARTRATE_MEAN_MAX)

elevatedHeartrateStd = ->
	randomInRange(
		heartrateConfig.ELEVATED_HEARTRATE_STD_MIN
		, heartrateConfig.ELEVATED_HEARTRATE_STD_MAX)

elevatedHeartrateInterpretation = ->
	heartrateConfig.ELEVATED_HEARTRATE_INTERPRETATION

normalHeartrateMean = ->
	randomInRange(
		heartrateConfig.NORMAL_HEARTRATE_MEAN_MIN
		, heartrateConfig.NORMAL_HEARTRATE_MEAN_MAX)

normalHeartrateStd = ->
	randomInRange(
		heartrateConfig.NORMAL_HEARTRATE_STD_MIN
		, heartrateConfig.NORMAL_HEARTRATE_STD_MAX)

normalHeartrateInterpretation = ->
	heartrateConfig.NORMAL_HEARTRATE_INTERPRETATION


module.exports = generateBotHeartrate