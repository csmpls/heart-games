
randomInRange = require 'random-number-in-range'
heartrateConfig = require('./config.coffee').heartrateConditionConfig

exports.elevatedHeartrateMean = ->
	randomInRange(
		heartrateConfig.ELEVATED_HEARTRATE_MEAN_MIN
		, heartrateConfig.ELEVATED_HEARTRATE_MEAN_MAX)

exports.elevatedHeartrateStd = ->
	randomInRange(
		heartrateConfig.ELEVATED_HEARTRATE_STD_MIN
		, heartrateConfig.ELEVATED_HEARTRATE_STD_MAX)

exports.elevatedHeartrateInterpretation = ->
	heartrateConfig.ELEVATED_HEARTRATE_INTERPRETATION

exports.normalHeartrateMean = ->
	randomInRange(
		heartrateConfig.NORMAL_HEARTRATE_MEAN_MIN
		, heartrateConfig.NORMAL_HEARTRATE_MEAN_MAX)

exports.normalHeartrateStd = ->
	randomInRange(
		heartrateConfig.NORMAL_HEARTRATE_STD_MIN
		, heartrateConfig.NORMAL_HEARTRATE_STD_MAX)

exports.normalHeartrateInterpretation = ->
	heartrateConfig.NORMAL_HEARTRATE_INTERPRETATION
