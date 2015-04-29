

$ = require 'jquery'
_ = require 'lodash'

getSurveyLinkView = (url) ->
	_.template('''
		<h2>The game portion is now complete.</h2>

		<p> To finish the experiment, please <b><a href="<%= url %>">complete this survey</a></b>. Thank you for participating!</p>
		''')(url:url)

setup = (surveyURL) -> $('#container').html(getSurveyLinkView(surveyURL))

exports.setup = setup