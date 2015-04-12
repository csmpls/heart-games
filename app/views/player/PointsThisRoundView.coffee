_ = require 'lodash'
$ = require 'jquery'

pointsViewTemplate = (points) ->
	_.template('points this round: <br> <%= points %>')(points:points)

setup = (points) -> $('#pointsSidebar').html(pointsViewTemplate(points))

exports.setup = setup
