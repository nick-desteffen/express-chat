Express = require('express')
Http    = require('http')
Https   = require('https')
Path    = require('path')
Faye    = require('faye')
Crypto  = require('crypto')
Redis   = require('redis')

redis  = Redis.createClient()
redis.select(10)
bayeux = new Faye.NodeAdapter(mount: '/faye', timeout: 45)
faye   = bayeux.getClient()
app    = Express()

app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/views')
app.set('view engine', 'ejs')
app.use(Express.favicon())
app.use(Express.logger('dev'))
app.use(Express.bodyParser())
app.use(Express.methodOverride())
app.use(Express.cookieParser('your secret here'))
app.use(Express.session())
app.use(app.router)
app.use(require('less-middleware')({ src: __dirname + '/public' }))
app.use(Express.static(Path.join(__dirname, 'public')))

if 'development' is app.get('env')
  app.use(Express.errorHandler())

### Helpers ###

gravatarEmailHash = (email)->
  Crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')

joinChat = (email, room)->
  gravatarHash = gravatarEmailHash(email)
  options = {
    host: "secure.gravatar.com"
    port: 443
    path: "/#{gravatarHash}.json"
    headers: {
      "User-Agent": "express-chat"
    }
  }

  output = ""
  get = Https.get options, (response) ->
    response.setEncoding('utf8')
    response.on "data", (chunk) ->
      output += chunk
    response.on "end", ()->
      if response.statusCode is 200
        gravatar_profile = JSON.parse(output).entry[0]
        location = gravatar_profile.currentLocation || 'Unknown'

        if gravatar_profile.name
          name = gravatar_profile.name.formatted
        else
          name = gravatar_profile.displayName

        payload = {
          name:     name,
          email:    email,
          location: location,
          gravatar: gravatarHash
        }
      else
        payload = {
          name:     "Anonymous",
          email:    email,
          location: "Unknown",
          gravatar: gravatarHash
        }

      redis.sadd("people:#{room}", JSON.stringify(payload))
      redis.sadd("rooms", room)
      faye.publish "/people/#{room}", payload

  get.on "error", (error) ->
    console.log "Error retrieving Gravatar profile: #{error.message}"

  get.end()

### Routes ###

## Index
app.get '/', (request, response)->
  redis.smembers "rooms", (error, rooms)->
    response.render('index', {rooms: rooms})

## Chatroom
app.post '/chat', (request, response)->
  email = request.body.email
  room  = request.body.room
  joinChat(email, room)

  redis.lrange "chat:#{room}", 0, -1, (error, messages)->
    redis.smembers "people:#{room}", (error, people)->
      response.render('chat', {email: email, room: room, messages: messages, people: people})

## Submit message
app.post '/message', (request, response)->
  email = request.body.email
  body  = request.body.body
  room  = request.body.room

  payload = {
    email:     email,
    body:      body,
    gravatar:  gravatarEmailHash(email),
    timestamp: new Date().toString()
  }

  redis.lpush("chat:#{room}", JSON.stringify(payload))
  faye.publish "/chat-messages/#{room}", payload
  response.send(201)

### Server Configuration ###

server = Http.createServer(app)
bayeux.attach(server)

server.listen app.get('port'), ()->
  console.log("Express server listening on port #{app.get('port')}")

