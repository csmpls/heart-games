
_ = require 'lodash'
$ = require 'jquery'

headerBarView = (subject_id, station_num, bank) ->
	_.template('''

		<div class = "headerDiv">
			Subject ID: <%= subject_id %>
		</div>

		<div class = "headerDiv">
			Station: <%= station_num %>
		</div>

		<div class = "headerDiv">
			Bank: <%= bank %>	
			</div>

		''')(
		subject_id: subject_id
		station_num: station_num
		bank: bank)

setup = (subject_id, station_num, bank) ->
	# put view html in #header
	$('#header').html(headerBarView(subject_id, station_num, bank))

exports.setup = setup 

