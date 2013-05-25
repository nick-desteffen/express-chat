Express = require('express')
Http    = require('http')
Path    = require('path')
Faye    = require('faye')
Crypto  = require('crypto')
Redis   = require('redis')

redis = Redis.createClient()

gravatarBaseURL = "https://secure.gravatar.com/avatar/"

bayeux = new Faye.NodeAdapter(mount: '/faye', timeout: 45)
faye  = bayeux.getClient()

app = Express()

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

### Routes ###

## Index
app.get '/', (request, response)->
  response.render('index')

## Chatroom
app.post '/chat', (request, response)->
  email = request.body.email
  gravatar = gravatarBaseURL + Crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')

  redis.llen "chat", (error, message_count)->
    redis.lrange "chat", 0, message_count, (error, messages)->
      response.render('chat', {email: email, gravatar: gravatar, messages: messages})

## Submit message
app.post '/message', (request, response)->
  email    = request.body.email
  body     = request.body.body
  gravatar = gravatarBaseURL + Crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')

  payload = {
    email:    email,
    body:     body,
    gravatar: gravatar
  }

  redis.lpush('chat', JSON.stringify(payload))
  faye.publish "/chat-messages", payload
  response.send(payload)

### Server Configuration ###

server = Http.createServer(app)
bayeux.attach(server)

server.listen app.get('port'), ()->
  console.log("Express server listening on port #{app.get('port')}")

