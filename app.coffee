express = require('express')
fs = require('fs')
http = require('http')
socket_io = require('socket.io')
morgan = require('morgan')
zerorpc = require('zerorpc')

# Init RPC and get state
rpcclient = new zerorpc.Client()
rpcclient.connect "tcp://127.0.0.1:4242"
playing = false
rpcclient.on 'error', (error) ->
  console.error 'RPC error: ', error
rpcclient.invoke 'is_playing', (error, response, more) ->
  console.log 'Got state from player: is ', response
  playing = response

# Init
app = express()
server = http.createServer(app)
io = socket_io(server)


app.use morgan('dev')
app.set 'views', './views'
app.set 'view engine', 'jade'

#app.use (req, res, next) ->
#  if req.sequre
#    next()

app.get '/', (req, res) ->
  res.render 'index'

app.use express.static('public')

io.on 'connection', (socket) ->
  event = if playing then 'playing' else 'stopped'
  socket.emit event
  socket.on 'start', (socket) ->
    unless playing
      console.log 'Start requested'
      rpcclient.invoke 'play', (error, response, more) ->
        if error
          console.error 'RPC error: ', error
        else if response
          console.log 'Started playing'
          io.sockets.emit 'playing'
          playing = true

#https_options =
#  key: fs.readFileSync 'keys/focplay-key.pem'
#  cert: fs.readFileSync 'keys/focplay-cert.pem'

server.listen 8080, ->
  console.log 'Listening on port 8080'
