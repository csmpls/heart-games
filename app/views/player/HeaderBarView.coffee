
_ = require 'lodash'
$ = require 'jquery'

headerBarView = (subject_id, station_num, bank) ->
	_.template('''

		Your subject id: <%= subject_id %>

		Station: <%= station_num %>

		Bank: <%= bank %>	

		''')(
		subject_id: subject_id
		station_num: station_num
		bank: bank)

setup = (subject_id, station_num, bank) ->
	# put view html in #header
	$('#header').html(headerBarView(subject_id, station_num, bank))

exports.setup = setup 

