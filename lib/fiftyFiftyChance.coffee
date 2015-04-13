
randomInRange = require 'random-number-in-range'
config = require './config'

# 50% chance of returning true/false
fiftyFiftyChance = -> if randomInRange(0,10)<5 then true else false

module.exports = fiftyFiftyChance