path = require 'path'
express = require "express"
app = express()
server = require('http').Server(app);
io = require('socket.io')(server);

# app.set 'port', process.env.PORT ? 3000
port = 3000
publicDir = "#{__dirname}/built-app"
# viewsDir = "#{__dirname}/views"
# lib = "#{viewsDir}/lib"
# app.set('public', publicDir)
app.use(express.static(publicDir))
# app.use(express.logger())
# app.use(express.bodyParser())

server.listen(port)
console.log 'server listening on ' + port

app.get("/", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'player.html')))

app.get("/admin", (req, res) ->
	res.sendFile(
		path.join(publicDir, 'admin.html')))

io.on('connection', (socket) ->
  socket.emit('news', { hello: 'world' })
  socket.on('my other event', (data) -> 
    console.log(data)))

# app.listen app.get('port'), ->
#   console.log 'listening on port %d', app.get('port')