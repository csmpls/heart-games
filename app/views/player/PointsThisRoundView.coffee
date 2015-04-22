_ = require 'lodash'
$ = require 'jquery'

pointsViewTemplate = (points) ->
	_.template('Your Points: <%= points %>')(points:points)

setup = (points) -> $('#pointsSidebar').html(pointsViewTemplate(points))

exports.setup = setup
