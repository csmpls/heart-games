module.exports = (grunt) ->

	grunt.initConfig

		coffeeify: 
			player: 
				files: [
					src: ['app/views/player/*.coffee', 'app/lib/*.coffee', 'app/player-main.coffee'],
					dest: 'built-app/player_bundle.js'
				]
			admin: 
				files: [
					src: ['app/views/admin/*.coffee', 'app/lib/*.coffee', 'app/admin-main.coffee'],
					dest: 'built-app/admin_bundle.js'
				]
		copy:
			playerHTML:
				src: 'app/player.html'
				dest: 'built-app/player.html'
			adminHTML:
				src: 'app/admin.html'
				dest: 'built-app/admin.html'
			assets:
				expand: true
				cwd: 'app/assets/'
				src: '**'
				dest: 'built-app/assets/'
				flatten: true
				filter: 'isFile'

		express:
			dev:
				options:
					port: 3000
					debug: true
					opts: ['node_modules/coffee-script/bin/coffee']
					script: 'server.coffee'

		uglify:
			production:
				files: 'built-app/player_bundle.js': ['built-app/player_bundle.js']
		watch:
			coffeeify:
				files: ['app/views/**/*.coffee', 'app/lib/*.coffee', 'app/player-main.coffee', 'app/admin-main.coffee']
				tasks: ['coffeeify:player', 'coffeeify:admin']
			copy:
				files: ['app/player.html', 'app/admin.html', 'app/assets/*']
				tasks: ['copy:playerHTML', 'copy:adminHTML', 'copy:assets']
			sass:
				files: ['app/styles/*.scss']
				tasks: ['sass:compile']
			express:
				files: ['server.coffee', 'modules/*']
				tasks: ['express:dev']

					
	grunt.loadNpmTasks 'grunt-coffeeify'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-express-server'
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['coffeeify', 'copy']
