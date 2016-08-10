# heart-games

this is a prisoners dilemna with choice, against an automated confederate.

## developing

make sure you have `node`, `npm` and `grunt`

then just

```npm install```

you'll need to add a file *modues/db_config.coffee* that looks like this (sorry!):

```coffee
Sequelize = require 'sequelize'

module.exports = () ->
  new Sequelize('postgres://[username]:[pass].@[db-hostname]:[db-port]/[db-name]')
```

now, `npm start` to run the server.

the admin interface is at http://[server-url]/admin

## front-end app

while changing stuff in `app/*`, you'll want to `grunt watch` to continually re-build the JS frontend on changes.

the directory structure is like this:

```
app/ <- this is the webapp 
    styles/ <-- sass files here
    assets/ <-- everything 
	lib/ <- these are your common js-style coffeescript files
	index.html <- the main html template
	main.coffee <- entry point for the webapp  - start reading here
```

`grunt` tasks compile `app/` to a neat bundle in the top-level directory `built-app/`. this is what gets served by the server.

## back-end app

round info is saved to the postgres DB after each round

in modules/, look at the `module.exports` to see the exposed methods

