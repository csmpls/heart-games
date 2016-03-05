
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

	#didHumanScrewMeOver = didPlayerDefect(humanPlayerState)

	# condition 2: always return an elevated heartrate 
	if elevatedHeartrateCondition == 2
		return generateElevatedHeartrate()

	# condition 1: return an elevated heartrate if the human screwed the bot over
	#if didHumanScrewMeOver and elevatedHeartrateCondition == 1
	#	return generateElevatedHeartrate() 

	# condition 0: always return a normal heartrate
	return  generateNormalHeartrate() 

###
given the last round (humanPlayerState), and the subject's condition (elevatedHeartrateCondition), this function generates the heartrate that the player sees after the round is over.

for starters, we just elevate the heartrate whenever player screws over the other player, assuming elevatedHeartrateCondition is true.

returns {mean, std, interpretation}

###

didPlayerDefect = (playerState) -> playerState.cooperateDefectTurn.decision == 'defect'

generateElevatedHeartrate = ->
	console.log(normalHeartrateInterpretation())
	return {
		mean: elevatedHeartrateMean()
		std: elevatedHeartrateStd()
		interpretation: elevatedHeartrateInterpretation() 
	}

generateNormalHeartrate = ->
	console.log(normalHeartrateInterpretation())
	return {
		mean: normalHeartrateMean()
		std: normalHeartrateStd()
		interpretation: normalHeartrateInterpretation() 
	}

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