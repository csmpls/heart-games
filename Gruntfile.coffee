module.exports = (grunt) ->

	grunt.initConfig

		coffeeify: 
			player: 
				files: [
					src: ['app/lib/*.coffee', 'app/player-main.coffee'],
					dest: 'built-app/player_bundle.js'
				]
			admin: 
				files: [
					src: ['app/lib/*.coffee', 'app/admin-main.coffee'],
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
		sass:
			compile:
				files:
					'built-app/style.css': 'app/styles/main.scss'
		express:
			dev:
				options:
					port: 3000
					debug: true
					opts: ['node_modules/coffee-script/bin/coffee']
					script: 'server.coffee'
		watch:
			coffeeify:
				files: ['app/lib/*.coffee', 'app/main.coffee']
				tasks: ['coffeeify:player', 'coffeeify:admin']
			copy:
				files: ['app/index.html', 'app/assets/*']
				tasks: ['copy:playerHTML', 'copy:adminwHTML', 'copy:assets']
			sass:
				files: ['app/styles/*.scss']
				tasks: ['sass:compile']
			express:
				files: ['server.coffee']
				tasks: ['express:dev']

					
	grunt.loadNpmTasks 'grunt-coffeeify'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-express-server'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['coffeeify', 'copy', 'sass']
